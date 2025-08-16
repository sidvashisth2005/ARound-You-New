import React, { useState } from 'react';
import { Button } from './ui/button';
import { ArrowLeft, Camera, Mic, Type, Image, Video, Check } from 'lucide-react';

interface ARMemoryScreenProps {
  onBack: () => void;
}

export function ARMemoryScreen({ onBack }: ARMemoryScreenProps) {
  const [selectedMemoryType, setSelectedMemoryType] = useState<'photo' | 'video' | 'audio' | 'text' | null>(null);
  const [isPlacing, setIsPlacing] = useState(false);
  const [isPlaced, setIsPlaced] = useState(false);

  const memoryTypes = [
    { type: 'photo' as const, icon: Image, color: '#00FFF7', label: 'Photo' },
    { type: 'video' as const, icon: Video, color: '#FF00A8', label: 'Video' },
    { type: 'audio' as const, icon: Mic, color: '#B400FF', label: 'Audio' },
    { type: 'text' as const, icon: Type, color: '#FFD700', label: 'Text' },
  ];

  const handlePlaceMemory = () => {
    setIsPlacing(true);
    setTimeout(() => {
      setIsPlacing(false);
      setIsPlaced(true);
    }, 2000);
  };

  return (
    <div className="min-h-screen dark-gradient-bg text-white relative overflow-hidden">
      {/* Camera View Background */}
      <div className="absolute inset-0 bg-gradient-to-br from-gray-800 via-gray-700 to-gray-900">
        {/* Simulated camera feed with grid overlay */}
        <div className="absolute inset-0 opacity-20">
          <svg width="100%" height="100%">
            <defs>
              <pattern id="camera-grid" width="100" height="100" patternUnits="userSpaceOnUse">
                <path d="M 100 0 L 0 0 0 100" fill="none" stroke="#00FFF7" strokeWidth="1"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#camera-grid)" />
          </svg>
        </div>
        
        {/* Simulated environment elements */}
        <div className="absolute bottom-0 left-0 w-full h-32 bg-gradient-to-t from-green-900/30 to-transparent"></div>
        <div className="absolute top-1/3 right-1/4 w-24 h-40 bg-gray-600/40 rounded-lg"></div>
        <div className="absolute top-1/2 left-1/3 w-16 h-20 bg-gray-700/30 rounded"></div>
      </div>

      {/* Back Button */}
      <div className="absolute top-6 left-6 z-30">
        <Button
          onClick={onBack}
          variant="ghost"
          className="w-12 h-12 rounded-full glass-panel border-white/20 text-white hover:neon-glow-cyan"
        >
          <ArrowLeft className="w-6 h-6" />
        </Button>
      </div>

      {/* Placement Indicator */}
      {selectedMemoryType && !isPlaced && (
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-20">
          <div className={`w-24 h-24 rounded-full ${isPlacing ? 'animate-spin' : 'animate-pulse'}`}>
            {/* Holographic circle */}
            <div className="absolute inset-0 rounded-full border-4 border-[#00FFF7] opacity-60"></div>
            <div className="absolute inset-2 rounded-full border-2 border-[#00FFF7] opacity-40"></div>
            <div className="absolute inset-4 rounded-full border-1 border-[#00FFF7] opacity-20"></div>
            
            {/* Ripple effect */}
            {!isPlacing && (
              <>
                <div className="absolute inset-0 rounded-full border-2 border-[#00FFF7] animate-ping"></div>
                <div className="absolute inset-0 rounded-full bg-[#00FFF7]/10"></div>
              </>
            )}
            
            {/* Center dot */}
            <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-4 h-4 rounded-full bg-[#00FFF7] neon-glow-cyan"></div>
          </div>
        </div>
      )}

      {/* Success Indicator */}
      {isPlaced && (
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-20">
          <div className="w-24 h-24 rounded-full bg-green-500/20 border-4 border-green-400 flex items-center justify-center neon-glow-cyan">
            <Check className="w-12 h-12 text-green-400" />
          </div>
        </div>
      )}

      {/* Memory Type Carousel */}
      {!isPlaced && (
        <div className="absolute bottom-32 left-0 right-0 z-20 px-6">
          <div className="flex space-x-4 overflow-x-auto pb-4">
            {memoryTypes.map((memory) => (
              <div
                key={memory.type}
                onClick={() => setSelectedMemoryType(memory.type)}
                className={`min-w-[120px] glass-panel rounded-2xl p-4 cursor-pointer transition-all duration-200 ${
                  selectedMemoryType === memory.type 
                    ? 'neon-glow-cyan scale-105' 
                    : 'hover:scale-105'
                }`}
              >
                <div className="flex flex-col items-center space-y-2">
                  <div 
                    className="w-12 h-12 rounded-full flex items-center justify-center"
                    style={{ backgroundColor: `${memory.color}20` }}
                  >
                    <memory.icon 
                      className="w-6 h-6" 
                      style={{ color: memory.color }}
                    />
                  </div>
                  <span className="text-sm font-medium">{memory.label}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Floating Toolbar */}
      {selectedMemoryType && !isPlaced && (
        <div className="absolute right-6 top-1/2 transform -translate-y-1/2 z-20">
          <div className="flex flex-col space-y-4">
            <Button
              className="w-12 h-12 rounded-full glass-panel border-white/20 text-[#00FFF7] hover:neon-glow-cyan"
            >
              <Type className="w-6 h-6" />
            </Button>
            <Button
              className="w-12 h-12 rounded-full glass-panel border-white/20 text-[#FF00A8] hover:neon-glow-magenta"
            >
              <Camera className="w-6 h-6" />
            </Button>
            <Button
              className="w-12 h-12 rounded-full glass-panel border-white/20 text-[#B400FF] hover:neon-glow-purple"
            >
              <Mic className="w-6 h-6" />
            </Button>
          </div>
        </div>
      )}

      {/* Place Memory Button */}
      {selectedMemoryType && !isPlacing && !isPlaced && (
        <div className="absolute bottom-6 left-6 right-6 z-20">
          <Button
            onClick={handlePlaceMemory}
            className="w-full h-14 rounded-2xl cyberpunk-gradient border-0 neon-glow-cyan text-black font-bold text-lg"
          >
            Place Memory
          </Button>
        </div>
      )}

      {/* Placed Memory Actions */}
      {isPlaced && (
        <div className="absolute bottom-6 left-6 right-6 z-20 space-y-4">
          <Button
            onClick={onBack}
            className="w-full h-14 rounded-2xl cyberpunk-gradient border-0 neon-glow-cyan text-black font-bold text-lg"
          >
            View on Map
          </Button>
          <Button
            onClick={() => {
              setIsPlaced(false);
              setSelectedMemoryType(null);
            }}
            variant="outline"
            className="w-full h-12 rounded-xl glass-panel border-white/20 text-white hover:neon-glow-magenta"
          >
            Place Another
          </Button>
        </div>
      )}

      {/* AR Instructions */}
      {!selectedMemoryType && (
        <div className="absolute top-1/3 left-6 right-6 z-20">
          <div className="glass-panel rounded-2xl p-6 text-center">
            <h2 className="text-xl font-bold mb-2">Drop an AR Memory</h2>
            <p className="text-white/70">
              Choose a memory type below and point your camera at the location where you want to place it.
            </p>
          </div>
        </div>
      )}
    </div>
  );
}