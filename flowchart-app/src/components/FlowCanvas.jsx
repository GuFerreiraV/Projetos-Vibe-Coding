import React, { useState, useRef, useCallback } from 'react';
import ReactFlow, {
    ReactFlowProvider,
    addEdge,
    useNodesState,
    useEdgesState,
    Controls,
    Background,
    MiniMap,
    applyEdgeChanges, applyNodeChanges,
    getRectOfNodes,
    getTransformForBounds
} from 'reactflow';
import 'reactflow/dist/style.css';
import { Save, Download, Cloud, Trash2 } from 'lucide-react';
import { toPng, toSvg } from 'html-to-image';
import { nodeTypes } from './CustomNodes';
import RenameModal from './RenameModal';

const initialNodes = [
    {
        id: '1',
        type: 'start',
        data: { label: 'Start' },
        position: { x: 250, y: 5 },
    },
];

let id = 0;
const getId = () => `dndnode_${id++}`;

const FlowCanvas = () => {
    const reactFlowWrapper = useRef(null);
    const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes);
    const [edges, setEdges, onEdgesChange] = useEdgesState([]);
    const [reactFlowInstance, setReactFlowInstance] = useState(null);

    // Modal State
    const [modalOpen, setModalOpen] = useState(false);
    const [modalTitle, setModalTitle] = useState('');
    const [modalValue, setModalValue] = useState('');
    const [editingItem, setEditingItem] = useState(null); // { type: 'node' | 'edge', id: string }

    const onConnect = useCallback(
        (params) => setEdges((eds) => addEdge({ ...params, type: 'smoothstep', label: '' }, eds)),
        [],
    );

    const onDragOver = useCallback((event) => {
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move';
    }, []);

    const onDrop = useCallback(
        (event) => {
            event.preventDefault();

            const type = event.dataTransfer.getData('application/reactflow');
            const label = event.dataTransfer.getData('application/reactflow/label');

            if (typeof type === 'undefined' || !type) {
                return;
            }

            const position = reactFlowInstance.screenToFlowPosition({
                x: event.clientX,
                y: event.clientY,
            });

            const newNode = {
                id: getId(),
                type,
                position,
                data: { label: label || `${type}` },
            };

            setNodes((nds) => nds.concat(newNode));
        },
        [reactFlowInstance],
    );

    // Renaming Logic with Modal
    const onNodeDoubleClick = useCallback((event, node) => {
        setModalTitle('Rename Node');
        setModalValue(node.data.label);
        setEditingItem({ type: 'node', id: node.id });
        setModalOpen(true);
    }, []);

    const onEdgeDoubleClick = useCallback((event, edge) => {
        setModalTitle('Edit Connection Label');
        setModalValue(edge.label || '');
        setEditingItem({ type: 'edge', id: edge.id });
        setModalOpen(true);
    }, []);

    const handleRenameSave = (newValue) => {
        if (editingItem?.type === 'node') {
            setNodes((nds) =>
                nds.map((n) => {
                    if (n.id === editingItem.id) {
                        // Keep other data properties, just update label
                        n.data = { ...n.data, label: newValue };
                    }
                    return n;
                })
            );
        } else if (editingItem?.type === 'edge') {
            setEdges((eds) =>
                eds.map((e) => {
                    if (e.id === editingItem.id) {
                        e.label = newValue;
                    }
                    return e;
                })
            );
        }
        setModalOpen(false);
        setEditingItem(null);
    };

    const onDeleteSelected = useCallback(() => {
        setNodes((nds) => nds.filter((node) => !node.selected));
        setEdges((eds) => eds.filter((edge) => !edge.selected));
    }, [setNodes, setEdges]);

    // Enhanced Export Logic
    const downloadImage = async (format) => {
        // We target the viewport to ensure we capture all nodes/edges regardless of current view
        const viewport = document.querySelector('.react-flow__viewport');

        if (!viewport) {
            console.error('Viewport not found');
            return;
        }

        // Calculate bounds of all nodes
        const nodesBounds = getRectOfNodes(nodes);

        // Add padding
        const padding = 50;
        const imageWidth = nodesBounds.width + (padding * 2);
        const imageHeight = nodesBounds.height + (padding * 2);

        const options = {
            backgroundColor: '#0f172a',
            width: imageWidth,
            height: imageHeight,
            style: {
                width: imageWidth,
                height: imageHeight,
                // Shift the content so that the top-left node is at (padding, padding)
                transform: `translate(${-nodesBounds.x + padding}px, ${-nodesBounds.y + padding}px)`,
            },
        };

        const exportFn = format === 'svg' ? toSvg : toPng;

        try {
            const dataUrl = await exportFn(viewport, options);
            const link = document.createElement('a');
            link.download = `flowchart-export.${format}`;
            link.href = dataUrl;
            link.click();
        } catch (err) {
            console.error('Export failed', err);
        }
    };

    const saveToDrive = () => {
        alert("Integration with Google Drive would be implemented here! (Requires API Key/Auth)");
    };

    return (
        <div className="flow-canvas-wrapper" ref={reactFlowWrapper}>
            <div className="toolbar">
                <button onClick={() => downloadImage('png')} title="Export as PNG">
                    <Download size={18} /> PNG
                </button>
                <button onClick={() => downloadImage('svg')} title="Export as SVG">
                    <Download size={18} /> SVG
                </button>
                <button onClick={saveToDrive} title="Save to Google Drive">
                    <Cloud size={18} /> Drive
                </button>
                <div style={{ width: 1, height: 24, background: 'var(--color-border)', margin: '0 8px' }}></div>
                <button onClick={onDeleteSelected} title="Delete Selected Node/Edge" style={{ color: '#f43f5e' }}>
                    <Trash2 size={18} /> Delete
                </button>
            </div>

            <ReactFlow
                nodes={nodes}
                edges={edges}
                onNodesChange={onNodesChange}
                onEdgesChange={onEdgesChange}
                onConnect={onConnect}
                onInit={setReactFlowInstance}
                onDrop={onDrop}
                onDragOver={onDragOver}
                onNodeDoubleClick={onNodeDoubleClick}
                onEdgeDoubleClick={onEdgeDoubleClick}
                nodeTypes={nodeTypes}
                fitView
                deleteKeyCode={['Backspace', 'Delete']}
            >
                <Controls />
                <Background color="#334155" gap={16} />
                <MiniMap style={{ background: '#1e293b' }} nodeColor={() => '#6366f1'} />
            </ReactFlow>

            <RenameModal
                isOpen={modalOpen}
                title={modalTitle}
                initialValue={modalValue}
                onClose={() => setModalOpen(false)}
                onSave={handleRenameSave}
            />
        </div>
    );
};

export default function FlowCanvasWrapper() {
    return (
        <ReactFlowProvider>
            <FlowCanvas />
        </ReactFlowProvider>
    );
}
