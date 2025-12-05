import React, { useState, useRef, useCallback } from 'react';
import ReactFlow, {
    ReactFlowProvider,
    addEdge,
    useNodesState,
    useEdgesState,
    Controls,
    Background,
    MiniMap,
    applyEdgeChanges, applyNodeChanges
} from 'reactflow';
import 'reactflow/dist/style.css';
import { Save, Download, Cloud, Trash2 } from 'lucide-react';
import { toPng, toSvg } from 'html-to-image';
import { nodeTypes } from './CustomNodes';

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

    const onNodeDoubleClick = useCallback((event, node) => {
        const label = window.prompt('Enter new label for this node:', node.data.label);
        if (label !== null) {
            setNodes((nds) =>
                nds.map((n) => {
                    if (n.id === node.id) {
                        n.data = { ...n.data, label };
                    }
                    return n;
                })
            );
        }
    }, [setNodes]);

    const onEdgeDoubleClick = useCallback((event, edge) => {
        const label = window.prompt('Enter label for join:', edge.label || '');
        if (label !== null) {
            setEdges((eds) =>
                eds.map((e) => {
                    if (e.id === edge.id) {
                        e.label = label;
                    }
                    return e;
                })
            );
        }
    }, [setEdges]);

    const onDeleteSelected = useCallback(() => {
        if (!reactFlowInstance) return;

        // Deleting via state is cleaner in this hook than using applyChanges manually on the raw array,
        // though ReactFlow handles 'Delete' key automatically. This button adds explicit UI action.
        const nodesToDelete = nodes.filter((n) => n.selected);
        const edgesToDelete = edges.filter((e) => e.selected);

        // We can use the setNodes/setEdges to filter out selected
        setNodes((nds) => nds.filter((node) => !node.selected));
        setEdges((eds) => eds.filter((edge) => !edge.selected));

    }, [nodes, edges, setNodes, setEdges, reactFlowInstance]);

    const downloadImage = (format) => {
        if (reactFlowWrapper.current === null) {
            return;
        }

        const exportFn = format === 'svg' ? toSvg : toPng;

        exportFn(reactFlowWrapper.current, { backgroundColor: '#0f172a' })
            .then((dataUrl) => {
                const link = document.createElement('a');
                link.download = `flowchart-export.${format}`;
                link.href = dataUrl;
                link.click();
            })
            .catch((err) => {
                console.error('oops, something went wrong!', err);
            });
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
