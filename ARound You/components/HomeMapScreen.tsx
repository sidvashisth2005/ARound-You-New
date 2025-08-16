import React, { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Avatar, AvatarFallback } from './ui/avatar';
import { 
  Search, 
  Plus, 
  Camera, 
  Users, 
  Trophy, 
  MapPin, 
  Navigation,
  User,
  Menu,
  Bell
} from 'lucide-react';

interface HomeMapScreenProps {
  onNavigate: (screen: 'onboarding' | 'login' | 'home' | 'ar-memory' | 'social' | 'chat' | 'achievements' | 'profile' | 'settings' | 'notifications' | 'help' | 'memory-details' | 'privacy' | 'terms') => void;
}

export function HomeMapScreen({ onNavigate }: HomeMapScreenProps) {
  const [activeUsers] = useState([
    { id: 1, x: 30, y: 40, name: 'Alex', color: '#00FFF7' },
    { id: 2, x: 60, y: 30, name: 'Sam', color: '#FF00A8' },
    { id: 3, x: 45, y: 70, name: 'Riley', color: '#B400FF' },
    { id: 4, x: 75, y: 55, name: 'Jordan', color: '#FFD700' },
  ]);

  const [memories] = useState([
    { id: 1, x: 25, y: 60, type: 'photo' },
    { id: 2, x: 70, y: 25, type: 'video' },
    { id: 3, x: 50, y: 80, type: 'audio' },
  ]);

  const [scavengerPaths] = useState([
    { id: 1, points: [{ x: 20, y: 20 }, { x: 35, y: 35 }, { x: 50, y: 25 }] },
    { id: 2, points: [{ x: 60, y: 60 }, { x: 75, y: 45 }, { x: 80, y: 70 }] },
  ]);

  return (
    <div className="min-h-screen dark-gradient-bg text-white relative overflow-hidden">
      {/* Header */}
      <div className="absolute top-0 left-0 right-0 z-20 p-4">
        <div className="flex items-center justify-between">
          {/* Search Bar */}
          <div className="flex-1 max-w-xs">
            <div className="glass-panel rounded-full px-4 py-2 flex items-center space-x-2">
              <Search className="w-4 h-4 text-[#00FFF7]" />
              <Input
                placeholder="Search places..."
                className="flex-1 bg-transparent border-0 text-white placeholder:text-white/50 focus:ring-0 p-0 text-sm"
              />
            </div>
          </div>

          {/* Right Header Icons */}
          <div className="flex items-center space-x-3">
            {/* Notifications */}
            <Button
              variant="ghost"
              size="icon"
              onClick={() => onNavigate('notifications')}
              className="w-10 h-10 rounded-full glass-panel border-white/20 hover:neon-glow-cyan relative"
            >
              <Bell className="w-5 h-5 text-[#00FFF7]" />
              {/* Notification dot */}
              <div className="absolute top-2 right-2 w-2 h-2 bg-[#FF00A8] rounded-full animate-pulse"></div>
            </Button>

            {/* Profile Avatar */}
            <Avatar 
              className="w-10 h-10 neon-glow-cyan cursor-pointer hover:scale-110 transition-transform duration-200"
              onClick={() => onNavigate('profile')}
            >
              <AvatarFallback className="bg-[#00FFF7]/20 text-[#00FFF7]">
                You
              </AvatarFallback>
            </Avatar>
          </div>
        </div>
      </div>

      {/* Map Container */}
      <div className="relative w-full h-screen bg-gradient-to-br from-gray-900/50 via-purple-900/30 to-blue-900/50">
        {/* Grid overlay for map feel */}
        <div className="absolute inset-0 opacity-10">
          <svg width="100%" height="100%">
            <defs>
              <pattern id="grid" width="50" height="50" patternUnits="userSpaceOnUse">
                <path d="M 50 0 L 0 0 0 50" fill="none" stroke="white" strokeWidth="0.5"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#grid)" />
          </svg>
        </div>

        {/* Active Users */}
        {activeUsers.map((user) => (
          <div
            key={user.id}
            className="absolute transform -translate-x-1/2 -translate-y-1/2 cursor-pointer"
            style={{ left: `${user.x}%`, top: `${user.y}%` }}
            onClick={() => onNavigate('social')}
          >
            {/* Pulsing circle */}
            <div className="relative">
              <div 
                className="w-16 h-16 rounded-full animate-ping absolute"
                style={{ backgroundColor: `${user.color}40` }}
              ></div>
              <div 
                className="w-8 h-8 rounded-full relative z-10 flex items-center justify-center"
                style={{ backgroundColor: user.color, boxShadow: `0 0 20px ${user.color}80` }}
              >
                <Users className="w-4 h-4 text-black" />
              </div>
            </div>
          </div>
        ))}

        {/* AR Memories */}
        {memories.map((memory) => (
          <div
            key={memory.id}
            className="absolute transform -translate-x-1/2 -translate-y-1/2 cursor-pointer hover:scale-125 transition-transform duration-200"
            style={{ left: `${memory.x}%`, top: `${memory.y}%` }}
            onClick={() => onNavigate('memory-details')}
          >
            <div className="w-6 h-6 rounded-full bg-[#FFD700] neon-glow-cyan animate-pulse flex items-center justify-center hover:neon-glow-magenta">
              <MapPin className="w-3 h-3 text-black" />
            </div>
          </div>
        ))}

        {/* Scavenger Hunt Paths */}
        {scavengerPaths.map((path) => (
          <svg
            key={path.id}
            className="absolute inset-0 w-full h-full pointer-events-none"
          >
            <path
              d={`M ${path.points.map(p => `${p.x}% ${p.y}%`).join(' L ')}`}
              fill="none"
              stroke="#B400FF"
              strokeWidth="2"
              strokeDasharray="10,5"
              className="animate-pulse"
              style={{ filter: 'drop-shadow(0 0 10px #B400FF)' }}
            />
            {path.points.map((point, index) => (
              <circle
                key={index}
                cx={`${point.x}%`}
                cy={`${point.y}%`}
                r="4"
                fill="#B400FF"
                className="animate-pulse"
                style={{ filter: 'drop-shadow(0 0 8px #B400FF)' }}
              />
            ))}
          </svg>
        ))}
      </div>

      {/* Floating Action Button - Drop Memory */}
      <div className="absolute bottom-24 left-1/2 transform -translate-x-1/2">
        <Button
          onClick={() => onNavigate('ar-memory')}
          className="w-16 h-16 rounded-full cyberpunk-gradient border-0 neon-glow-cyan animate-pulse-glow hover:scale-110 transition-transform duration-200"
        >
          <Plus className="w-8 h-8 text-black" />
        </Button>
      </div>

      {/* AR Mode Toggle */}
      <div className="absolute right-4 top-1/2 transform -translate-y-1/2">
        <Button
          onClick={() => onNavigate('ar-memory')}
          className="w-12 h-12 rounded-full glass-panel border-white/20 neon-glow-purple"
        >
          <Camera className="w-6 h-6 text-[#B400FF]" />
        </Button>
      </div>

      {/* Bottom Navigation */}
      <div className="absolute bottom-4 left-4 right-4">
        <div className="glass-panel rounded-2xl p-2">
          <div className="flex justify-around items-center">
            <Button
              variant="ghost"
              className="flex-1 h-12 text-[#00FFF7] hover:bg-[#00FFF7]/20"
            >
              <Navigation className="w-6 h-6" />
            </Button>
            <Button
              variant="ghost"
              className="flex-1 h-12 text-white/70 hover:bg-white/10"
              onClick={() => onNavigate('social')}
            >
              <Users className="w-6 h-6" />
            </Button>
            <Button
              variant="ghost"
              className="flex-1 h-12 text-white/70 hover:bg-white/10"
              onClick={() => onNavigate('achievements')}
            >
              <Trophy className="w-6 h-6" />
            </Button>
            <Button
              variant="ghost"
              className="flex-1 h-12 text-white/70 hover:bg-white/10"
              onClick={() => onNavigate('profile')}
            >
              <User className="w-6 h-6" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}