import React, { useState, useEffect, useRef } from 'react';

export default function RenameModal({ isOpen, initialValue, onClose, onSave, title }) {
    const [value, setValue] = useState(initialValue);
    const inputRef = useRef(null);

    useEffect(() => {
        setValue(initialValue);
        if (isOpen) {
            setTimeout(() => inputRef.current?.focus(), 100);
        }
    }, [initialValue, isOpen]);

    const handleSubmit = (e) => {
        e.preventDefault();
        onSave(value);
    };

    if (!isOpen) return null;

    return (
        <div style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(0, 0, 0, 0.5)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
            backdropFilter: 'blur(4px)'
        }}>
            <div style={{
                backgroundColor: '#1e293b',
                padding: '24px',
                borderRadius: '12px',
                border: '1px solid #334155',
                boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1)',
                width: '100%',
                maxWidth: '400px',
                animation: 'fadeIn 0.2s ease-out'
            }}>
                <h3 style={{ marginTop: 0, marginBottom: '16px', color: '#f8fafc' }}>{title}</h3>
                <form onSubmit={handleSubmit}>
                    <input
                        ref={inputRef}
                        type="text"
                        value={value}
                        onChange={(e) => setValue(e.target.value)}
                        style={{
                            width: '100%',
                            padding: '10px',
                            borderRadius: '6px',
                            border: '1px solid #475569',
                            background: '#0f172a',
                            color: 'white',
                            marginBottom: '20px',
                            fontSize: '16px',
                            boxSizing: 'border-box' // Fix padding width issue
                        }}
                    />
                    <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
                        <button
                            type="button"
                            onClick={onClose}
                            style={{
                                background: 'transparent',
                                border: '1px solid #475569'
                            }}
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            style={{
                                background: '#6366f1',
                                border: 'none'
                            }}
                        >
                            Save
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
