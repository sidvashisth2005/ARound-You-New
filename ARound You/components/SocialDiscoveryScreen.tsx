import React, { useState } from 'react';
import { Button } from './ui/button';
import { Avatar, AvatarFallback } from './ui/avatar';
import { ArrowLeft, MessageCircle, UserPlus, Heart, Star } from 'lucide-react';

interface SocialDiscoveryScreenProps {
  onBack: () => void;
  onStartChat: () => void;
}

export function SocialDiscoveryScreen({ onBack, onStartChat }: SocialDiscoveryScreenProps) {
  const [view, setView] = useState<'radar' | 'list'>('radar');
  
  const nearbyUsers = [
    { 
      id: 1, 
      name: 'Alex Chen', 
      distance: '~50m away', 
      angle: 45, 
      radius: 60, 
      avatar: 'AC', 
      color: '#00FFF7',
      interests: ['Photography', 'AR Art'],
      mutualFriends: 3
    },
    { 
      id: 2, 
      name: 'Sam Rivera', 
      distance: '~120m away', 
      angle: 135, 
      radius: 80, 
      avatar: 'SR', 
      color: '#FF00A8',
      interests: ['Gaming', 'Tech'],
      mutualFriends: 1
    },
    { 
      id: 3, 
      name: 'Riley Park', 
      distance: '~80m away', 
      angle: 225, 
      radius: 70, 
      avatar: 'RP', 
      color: '#B400FF',
      interests: ['Music', 'Travel'],
      mutualFriends: 5
    },
    { 
      id: 4, 
      name: 'Jordan Kim', 
      distance: '~200m away', 
      angle: 315, 
      radius: 90, 
      avatar: 'JK', 
      color: '#FFD700',
      interests: ['Art', 'Coffee'],
      mutualFriends: 0
    },
  ];

  return (
    <div className="min-h-screen dark-gradient-bg text-white relative overflow-hidden">
      {/* Header */}
      <div className="absolute top-0 left-0 right-0 z-20 p-4">
        <div className="flex items-center justify-between">
          <Button
            onClick={onBack}
            variant="ghost"
            className="w-12 h-12 rounded-full glass-panel border-white/20 text-white hover:neon-glow-cyan"
          >
            <ArrowLeft className="w-6 h-6" />
          </Button>
          
          <h1 className="text-xl font-bold">Around You</h1>
          
          <div className="flex space-x-2">
            <Button
              onClick={() => setView('radar')}
              variant={view === 'radar' ? 'default' : 'ghost'}
              className={`w-10 h-10 rounded-full ${
                view === 'radar' 
                  ? 'cyberpunk-gradient text-black' 
                  : 'glass-panel border-white/20 text-white'
              }`}
            >
              <div className="w-4 h-4 rounded-full border-2 border-current relative">
                <div className="w-1 h-1 bg-current rounded-full absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2"></div>
              </div>
            </Button>
            <Button
              onClick={() => setView('list')}
              variant={view === 'list' ? 'default' : 'ghost'}
              className={`w-10 h-10 rounded-full ${
                view === 'list' 
                  ? 'cyberpunk-gradient text-black' 
                  : 'glass-panel border-white/20 text-white'
              }`}
            >
              <div className="space-y-1">
                <div className="w-4 h-0.5 bg-current"></div>
                <div className="w-4 h-0.5 bg-current"></div>
                <div className="w-4 h-0.5 bg-current"></div>
              </div>
            </Button>
          </div>
        </div>
      </div>

      {view === 'radar' ? (
        /* Radar View */
        <div className="flex items-center justify-center min-h-screen relative">
          {/* Radar Background */}
          <div className="relative w-80 h-80">
            {/* Radar circles */}
            <div className="absolute inset-0">
              <div className="w-full h-full rounded-full border border-[#00FFF7]/30"></div>
              <div className="absolute inset-8 w-64 h-64 rounded-full border border-[#00FFF7]/20"></div>
              <div className="absolute inset-16 w-48 h-48 rounded-full border border-[#00FFF7]/10"></div>
              <div className="absolute inset-24 w-32 h-32 rounded-full border border-[#00FFF7]/10"></div>
            </div>
            
            {/* Radar sweep animation */}
            <div className="absolute inset-0 animate-spin" style={{ animationDuration: '4s' }}>
              <div 
                className="absolute top-1/2 left-1/2 w-40 h-0.5 origin-left transform -translate-y-1/2"
                style={{
                  background: 'linear-gradient(90deg, #00FFF7, transparent)',
                  filter: 'blur(1px)'
                }}
              ></div>
            </div>
            
            {/* Center - You */}
            <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
              <div className="w-8 h-8 rounded-full cyberpunk-gradient neon-glow-cyan flex items-center justify-center">
                <div className="w-4 h-4 rounded-full bg-black"></div>
              </div>
              <div className="text-xs text-center mt-2 font-medium">You</div>
            </div>
            
            {/* Nearby Users */}
            {nearbyUsers.map((user) => {
              const x = Math.cos((user.angle - 90) * Math.PI / 180) * user.radius;
              const y = Math.sin((user.angle - 90) * Math.PI / 180) * user.radius;
              
              return (
                <div
                  key={user.id}
                  className="absolute transform -translate-x-1/2 -translate-y-1/2 cursor-pointer group"
                  style={{ 
                    left: `calc(50% + ${x}px)`, 
                    top: `calc(50% + ${y}px)` 
                  }}
                  onClick={() => setView('list')}
                >
                  <div className="relative">
                    {/* Pulsing glow */}
                    <div 
                      className="w-8 h-8 rounded-full absolute animate-ping"
                      style={{ backgroundColor: `${user.color}40` }}
                    ></div>
                    
                    {/* User avatar */}
                    <Avatar className="w-6 h-6 relative z-10" style={{ boxShadow: `0 0 12px ${user.color}` }}>
                      <AvatarFallback 
                        className="text-xs text-black"
                        style={{ backgroundColor: user.color }}
                      >
                        {user.avatar}
                      </AvatarFallback>
                    </Avatar>
                    
                    {/* Tooltip on hover */}
                    <div className="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <div className="glass-panel rounded-lg px-2 py-1 text-xs whitespace-nowrap">
                        {user.name}
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
          
          {/* Distance Legend */}
          <div className="absolute bottom-24 left-6 right-6">
            <div className="glass-panel rounded-xl p-4">
              <div className="flex justify-between text-sm text-white/70">
                <span>50m</span>
                <span>100m</span>
                <span>150m</span>
                <span>200m+</span>
              </div>
            </div>
          </div>
        </div>
      ) : (
        /* List View */
        <div className="pt-20 pb-6">
          <div className="px-6 space-y-4">
            {nearbyUsers.map((user) => (
              <div key={user.id} className="glass-panel rounded-2xl p-4">
                <div className="flex items-center space-x-4">
                  <Avatar className="w-12 h-12" style={{ boxShadow: `0 0 12px ${user.color}` }}>
                    <AvatarFallback 
                      className="text-black font-medium"
                      style={{ backgroundColor: user.color }}
                    >
                      {user.avatar}
                    </AvatarFallback>
                  </Avatar>
                  
                  <div className="flex-1">
                    <div className="flex items-center space-x-2">
                      <h3 className="font-medium">{user.name}</h3>
                      {user.mutualFriends > 0 && (
                        <div className="flex items-center space-x-1 text-xs text-[#FFD700]">
                          <Star className="w-3 h-3 fill-current" />
                          <span>{user.mutualFriends}</span>
                        </div>
                      )}
                    </div>
                    <p className="text-sm text-white/70">{user.distance}</p>
                    <div className="flex flex-wrap gap-1 mt-1">
                      {user.interests.map((interest) => (
                        <span 
                          key={interest}
                          className="text-xs px-2 py-1 rounded-full bg-white/10 text-white/80"
                        >
                          {interest}
                        </span>
                      ))}
                    </div>
                  </div>
                  
                  <div className="flex space-x-2">
                    <Button
                      onClick={onStartChat}
                      className="w-10 h-10 rounded-full cyberpunk-gradient border-0 neon-glow-cyan"
                    >
                      <MessageCircle className="w-4 h-4 text-black" />
                    </Button>
                    <Button
                      variant="outline"
                      className="w-10 h-10 rounded-full glass-panel border-white/20 text-white hover:neon-glow-magenta"
                    >
                      <UserPlus className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}