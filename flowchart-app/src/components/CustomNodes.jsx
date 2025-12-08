import React, { memo } from 'react';
import { Handle, Position } from 'reactflow';
import { Database } from 'lucide-react';

const StartNode = memo(({ data }) => {
    return (
        <div style={{
            padding: '10px 20px',
            borderRadius: '20px',
            background: '#3b82f6',
            color: 'white',
            border: '1px solid #2563eb',
            textAlign: 'center',
            minWidth: '80px'
        }}>
            <Handle type="source" position={Position.Bottom} style={{ background: '#fff' }} />
            {data.label}
        </div>
    );
});

const EndNode = memo(({ data }) => {
    return (
        <div style={{
            padding: '10px 20px',
            borderRadius: '20px',
            background: '#ec4899',
            color: 'white',
            border: '1px solid #db2777',
            textAlign: 'center',
            minWidth: '80px'
        }}>
            <Handle type="target" position={Position.Top} style={{ background: '#fff' }} />
            {data.label}
        </div>
    );
});

const DecisionNode = memo(({ data }) => {
    return (
        <div style={{
            width: '100px',
            height: '100px',
            transform: 'rotate(45deg)',
            background: '#eab308',
            border: '1px solid #ca8a04',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            position: 'relative'
        }}>
            <div style={{ transform: 'rotate(-45deg)', color: 'white', textAlign: 'center' }}>
                {data.label}
            </div>

            <Handle type="target" position={Position.Top} style={{ top: 0, left: '50%', transform: 'translate(-50%, -50%)', background: 'white' }} />
            <Handle type="source" position={Position.Right} id="yes" style={{ top: '50%', right: 0, transform: 'translate(50%, -50%)', background: 'white' }} />
            <Handle type="source" position={Position.Bottom} id="no" style={{ bottom: 0, left: '50%', transform: 'translate(-50%, 50%)', background: 'white' }} />
            <Handle type="source" position={Position.Left} style={{ top: '50%', left: 0, transform: 'translate(-50%, -50%)', background: 'white' }} />
        </div>
    );
});

const ProcessNode = memo(({ data }) => {
    return (
        <div style={{
            padding: '10px 20px',
            borderRadius: '4px',
            background: '#6366f1',
            color: 'white',
            border: '1px solid #4f46e5',
            textAlign: 'center',
            minWidth: '100px'
        }}>
            <Handle type="target" position={Position.Top} style={{ background: '#fff' }} />
            <Handle type="source" position={Position.Bottom} style={{ background: '#fff' }} />
            {data.label}
        </div>
    );
});

const ManualInputNode = memo(({ data }) => {
    return (
        <div style={{
            width: '100px',
            padding: '10px',
            background: '#6366f1',
            clipPath: 'polygon(0 20%, 100% 0, 100% 100%, 0 100%)', // Trapezoid-ish
            color: 'white',
            textAlign: 'center',
            minHeight: '60px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginTop: '10px'
        }}>
            <Handle type="target" position={Position.Top} style={{ top: 0, background: '#fff' }} />
            <Handle type="source" position={Position.Bottom} style={{ bottom: 0, background: '#fff' }} />
            <span style={{ marginTop: '10px' }}>{data.label}</span>
        </div>
    );
});

const InputOutputNode = memo(({ data }) => {
    return (
        <div style={{
            width: '120px',
            padding: '10px',
            background: '#22c55e',
            transform: 'skew(-20deg)',
            color: 'white',
            textAlign: 'center',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: '50px',
            borderRadius: '4px'
        }}>
            <div style={{ transform: 'skew(20deg)' }}>{data.label}</div>
            <Handle type="target" position={Position.Top} style={{ left: '50%', transform: 'skew(20deg) translate(-50%, 0)', background: '#fff' }} />
            <Handle type="source" position={Position.Bottom} style={{ left: '50%', transform: 'skew(20deg) translate(-50%, 0)', background: '#fff' }} />
        </div>
    );
});

const DatabaseNode = memo(({ data }) => {
    return (
        <div style={{
            position: 'relative',
            minWidth: '80px',
            minHeight: '80px',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
        }}>
            <Database size={50} className="text-purple-500" />
            <div style={{ marginTop: '4px', textAlign: 'center' }}>{data.label}</div>

            <Handle type="target" position={Position.Top} style={{ background: '#fff', top: 0 }} />
            <Handle type="source" position={Position.Bottom} style={{ background: '#fff', bottom: 0 }} />
        </div>
    );
});

const SubprocessNode = memo(({ data }) => {
    return (
        <div style={{
            padding: '10px 20px',
            background: '#f43f5e',
            color: 'white',
            border: '1px solid #e11d48',
            textAlign: 'center',
            minWidth: '100px',
            position: 'relative'
        }}>
            <div style={{ position: 'absolute', left: '10px', top: 0, bottom: 0, borderLeft: '1px solid rgba(255,255,255,0.5)' }}></div>
            <div style={{ position: 'absolute', right: '10px', top: 0, bottom: 0, borderRight: '1px solid rgba(255,255,255,0.5)' }}></div>

            <Handle type="target" position={Position.Top} style={{ background: '#fff' }} />
            <Handle type="source" position={Position.Bottom} style={{ background: '#fff' }} />
            {data.label}
        </div>
    );
});

export const nodeTypes = {
    start: StartNode,
    end: EndNode,
    decision: DecisionNode,
    process: ProcessNode,
    manualInput: ManualInputNode,
    inputOutput: InputOutputNode,
    database: DatabaseNode,
    subprocess: SubprocessNode,
};
