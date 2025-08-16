import React from 'react';
import { Button } from './ui/button';
import { ArrowLeft, Trophy, MapPin, Users, Camera, Zap, Star } from 'lucide-react';

interface AchievementsScreenProps {
  onBack: () => void;
}

export function AchievementsScreen({ onBack }: AchievementsScreenProps) {
  const achievements = [
    {
      id: 1,
      title: 'First Memory',
      description: 'Drop your first AR memory',
      icon: Camera,
      color: '#00FFF7',
      earned: true,
      progress: 100
    },
    {
      id: 2,
      title: 'Social Explorer',
      description: 'Connect with 5 nearby users',
      icon: Users,
      color: '#FF00A8',
      earned: true,
      progress: 100
    },
    {
      id: 3,
      title: 'Trail Blazer',
      description: 'Complete 3 scavenger hunts',
      icon: MapPin,
      color: '#B400FF',
      earned: false,
      progress: 67
    },
    {
      id: 4,
      title: 'AR Master',
      description: 'Drop 50 AR memories',
      icon: Zap,
      color: '#FFD700',
      earned: false,
      progress: 24
    },
    {
      id: 5,
      title: 'Community Star',
      description: 'Get 100 likes on your memories',
      icon: Star,
      color: '#00FFF7',
      earned: false,
      progress: 43
    },
    {
      id: 6,
      title: 'Distance Walker',
      description: 'Walk 10km with the app',
      icon: Trophy,
      color: '#FF00A8',
      earned: false,
      progress: 78
    }
  ];

  const trails = [
    {
      id: 1,
      title: 'Downtown AR Hunt',
      description: 'Discover 5 hidden AR memories in downtown',
      difficulty: 'Easy',
      reward: '150 XP',
      participants: 24,
      mapSnippet: 'linear-gradient(45deg, #00FFF7, #FF00A8)'
    },
    {
      id: 2,
      title: 'Coffee Shop Stories',
      description: 'Find AR memories at 3 local coffee shops',
      difficulty: 'Medium',
      reward: '250 XP',
      participants: 18,
      mapSnippet: 'linear-gradient(45deg, #B400FF, #FFD700)'
    },
    {
      id: 3,
      title: 'Art District Explorer',
      description: 'Collect AR art pieces in the arts quarter',
      difficulty: 'Hard',
      reward: '400 XP',
      participants: 12,
      mapSnippet: 'linear-gradient(45deg, #FF00A8, #00FFF7)'
    }
  ];

  return (
    <div className="min-h-screen dark-gradient-bg text-white">
      {/* Header */}
      <div className="flex items-center p-4 glass-panel">
        <Button
          onClick={onBack}
          variant="ghost"
          className="w-10 h-10 rounded-full mr-3 text-white hover:neon-glow-cyan"
        >
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <h1 className="text-xl font-bold">Achievements & Trails</h1>
      </div>

      <div className="px-6 py-4 space-y-8">
        {/* Achievements Section */}
        <div>
          <h2 className="text-xl font-bold mb-4 cyberpunk-gradient bg-clip-text text-transparent">
            Achievements
          </h2>
          <div className="grid grid-cols-2 gap-4">
            {achievements.map((achievement) => (
              <div
                key={achievement.id}
                className={`glass-panel rounded-2xl p-4 relative overflow-hidden ${
                  achievement.earned ? 'neon-glow-cyan' : ''
                }`}
              >
                {/* 3D Badge Effect */}
                <div className="relative">
                  <div 
                    className={`w-16 h-16 rounded-full mx-auto mb-3 flex items-center justify-center transform ${
                      achievement.earned ? 'scale-110' : 'scale-100'
                    } transition-transform duration-200`}
                    style={{ 
                      backgroundColor: `${achievement.color}20`,
                      boxShadow: achievement.earned 
                        ? `0 0 20px ${achievement.color}60, 0 0 40px ${achievement.color}30`
                        : `0 0 10px ${achievement.color}30`
                    }}
                  >
                    <achievement.icon 
                      className="w-8 h-8" 
                      style={{ color: achievement.color }}
                    />
                  </div>
                  
                  {/* Completion indicator */}
                  {achievement.earned && (
                    <div className="absolute -top-2 -right-2 w-6 h-6 rounded-full bg-green-500 flex items-center justify-center neon-glow-cyan">
                      <Trophy className="w-3 h-3 text-black" />
                    </div>
                  )}
                </div>
                
                <h3 className="font-medium text-center text-sm mb-1">
                  {achievement.title}
                </h3>
                <p className="text-xs text-white/70 text-center mb-3">
                  {achievement.description}
                </p>
                
                {/* Progress bar */}
                <div className="w-full bg-white/10 rounded-full h-2">
                  <div 
                    className="h-2 rounded-full transition-all duration-500"
                    style={{ 
                      width: `${achievement.progress}%`,
                      background: `linear-gradient(90deg, ${achievement.color}, ${achievement.color}80)`
                    }}
                  ></div>
                </div>
                <p className="text-xs text-center mt-1 text-white/60">
                  {achievement.progress}%
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Trails Section */}
        <div>
          <h2 className="text-xl font-bold mb-4 cyberpunk-gradient bg-clip-text text-transparent">
            Active Trails
          </h2>
          <div className="space-y-4">
            {trails.map((trail) => (
              <div key={trail.id} className="glass-panel rounded-2xl p-4">
                <div className="flex items-start space-x-4">
                  {/* Map snippet */}
                  <div 
                    className="w-16 h-16 rounded-xl flex-shrink-0 relative overflow-hidden"
                    style={{ background: trail.mapSnippet }}
                  >
                    <div className="absolute inset-0 opacity-30">
                      <div className="absolute top-2 left-2 w-2 h-2 bg-white rounded-full"></div>
                      <div className="absolute bottom-2 right-2 w-1 h-1 bg-white rounded-full"></div>
                      <div className="absolute top-1/2 left-1/2 w-1.5 h-1.5 bg-white rounded-full transform -translate-x-1/2 -translate-y-1/2"></div>
                    </div>
                  </div>
                  
                  <div className="flex-1">
                    <div className="flex items-start justify-between mb-2">
                      <h3 className="font-medium">{trail.title}</h3>
                      <span 
                        className={`text-xs px-2 py-1 rounded-full ${
                          trail.difficulty === 'Easy' 
                            ? 'bg-green-500/20 text-green-400'
                            : trail.difficulty === 'Medium'
                            ? 'bg-yellow-500/20 text-yellow-400'
                            : 'bg-red-500/20 text-red-400'
                        }`}
                      >
                        {trail.difficulty}
                      </span>
                    </div>
                    
                    <p className="text-sm text-white/70 mb-3">
                      {trail.description}
                    </p>
                    
                    <div className="flex items-center justify-between text-xs text-white/60 mb-3">
                      <span>Reward: {trail.reward}</span>
                      <span>{trail.participants} participants</span>
                    </div>
                    
                    <Button className="w-full h-10 rounded-xl cyberpunk-gradient border-0 neon-glow-cyan text-black font-medium">
                      Start Trail
                    </Button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Stats Summary */}
        <div className="glass-panel rounded-2xl p-6">
          <h3 className="font-bold mb-4">Your Stats</h3>
          <div className="grid grid-cols-2 gap-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-[#00FFF7]">12</div>
              <div className="text-sm text-white/70">Memories Dropped</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-[#FF00A8]">8</div>
              <div className="text-sm text-white/70">Friends Made</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-[#B400FF]">2</div>
              <div className="text-sm text-white/70">Trails Completed</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-[#FFD700]">850</div>
              <div className="text-sm text-white/70">Total XP</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}