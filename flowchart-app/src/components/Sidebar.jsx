import React from 'react';
import { Square, Circle, Triangle, Diamond, Type, Database } from 'lucide-react';

export default function Sidebar() {
    const onDragStart = (event, nodeType, label) => {
        event.dataTransfer.setData('application/reactflow', nodeType);
        event.dataTransfer.setData('application/reactflow/label', label);
        event.dataTransfer.effectAllowed = 'move';
    };

    return (
        <aside className="sidebar">
            <h2><Square size={24} /> Toolbox</h2>
            <div className="description">Drag shapes to the canvas.</div>

            <div className="dndnode dndnode-input" onDragStart={(event) => onDragStart(event, 'start', 'Start')} draggable>
                <Circle size={20} className="text-blue-500" />
                Start
            </div>

            <div className="dndnode dndnode-default" onDragStart={(event) => onDragStart(event, 'process', 'Process')} draggable>
                <Square size={20} className="text-teal-500" />
                Process
            </div>

            <div className="dndnode dndnode-decision" onDragStart={(event) => onDragStart(event, 'decision', 'Decision')} draggable>
                <Diamond size={20} className="text-yellow-500" />
                Decision
            </div>

            <div className="dndnode dndnode-input-output" onDragStart={(event) => onDragStart(event, 'inputOutput', 'Input/Output')} draggable>
                <div style={{ width: 20, height: 16, transform: 'skew(-20deg)', border: '2px solid #22c55e', borderRadius: 2 }}></div>
                Input/Output
            </div>

            <div className="dndnode dndnode-manual-input" onDragStart={(event) => onDragStart(event, 'manualInput', 'Manual Input')} draggable>
                <div style={{ width: 20, height: 16, clipPath: 'polygon(0 20%, 100% 0, 100% 100%, 0 100%)', background: '#6366f1' }}></div>
                Manual Input
            </div>

            <div className="dndnode dndnode-database" onDragStart={(event) => onDragStart(event, 'database', 'Database')} draggable>
                <Database size={20} className="text-purple-500" />
                Database
            </div>

            <div className="dndnode dndnode-subprocess" onDragStart={(event) => onDragStart(event, 'subprocess', 'Subprocess')} draggable>
                <div style={{ width: 20, height: 16, border: '2px solid #f43f5e', position: 'relative' }}>
                    <div style={{ position: 'absolute', left: 3, top: 0, bottom: 0, borderLeft: '1px solid #f43f5e' }}></div>
                    <div style={{ position: 'absolute', right: 3, top: 0, bottom: 0, borderRight: '1px solid #f43f5e' }}></div>
                </div>
                Subprocess
            </div>

            <div className="dndnode dndnode-output" onDragStart={(event) => onDragStart(event, 'end', 'End')} draggable>
                <Circle size={20} className="text-pink-500" />
                End
            </div>
        </aside>
    );
}
