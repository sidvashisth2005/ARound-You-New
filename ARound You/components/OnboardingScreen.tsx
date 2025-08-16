import React from 'react';
import { Button } from './ui/button';
import { Globe, MapPin, Users, Trophy } from 'lucide-react';

interface OnboardingScreenProps {
  onGetStarted: () => void;
}

export function OnboardingScreen({ onGetStarted }: OnboardingScreenProps) {
  return (
    <div className="min-h-screen dark-gradient-bg text-white relative overflow-hidden">
      {/* Skip button */}
      <button 
        onClick={onGetStarted}
        className="absolute top-6 right-6 z-10 text-white/70 hover:text-white transition-colors"
      >
        Skip
      </button>

      {/* Content container */}
      <div className="flex flex-col items-center justify-center min-h-screen px-6 relative">
        {/* Animated background particles */}
        <div className="absolute inset-0 overflow-hidden">
          <div className="absolute top-1/4 left-1/4 w-2 h-2 bg-[#00FFF7] rounded-full animate-pulse opacity-60"></div>
          <div className="absolute top-1/3 right-1/3 w-1 h-1 bg-[#FF00A8] rounded-full animate-pulse opacity-40"></div>
          <div className="absolute bottom-1/4 left-1/3 w-3 h-3 bg-[#B400FF] rounded-full animate-pulse opacity-50"></div>
        </div>

        {/* Logo and title */}
        <div className="text-center mb-8">
          <h1 className="text-5xl font-bold mb-2 bg-gradient-to-r from-[#00FFF7] via-[#FF00A8] to-[#B400FF] bg-clip-text text-transparent" 
              style={{ 
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                filter: 'drop-shadow(0 0 20px rgba(0, 255, 247, 0.8)) drop-shadow(0 0 40px rgba(255, 0, 168, 0.6)) drop-shadow(0 0 60px rgba(180, 0, 255, 0.4))',
                textShadow: '0 0 30px rgba(0, 255, 247, 0.8), 0 0 60px rgba(255, 0, 168, 0.6), 0 0 90px rgba(180, 0, 255, 0.4)'
              }}>
            ARound You
          </h1>
          <p className="text-white/70 text-lg">Discover the world through AR</p>
        </div>

        {/* Holographic Earth */}
        <div className="relative mb-12">
          <div className="w-48 h-48 rounded-full glass-panel neon-glow-cyan animate-pulse-glow flex items-center justify-center mb-8">
            <Globe className="w-24 h-24 text-[#00FFF7] animate-spin" style={{ animationDuration: '20s' }} />
            {/* Floating dots representing users */}
            <div className="absolute inset-0">
              <div className="absolute top-8 left-12 w-2 h-2 bg-[#FFD700] rounded-full animate-pulse"></div>
              <div className="absolute bottom-12 right-8 w-2 h-2 bg-[#FF00A8] rounded-full animate-pulse"></div>
              <div className="absolute top-1/2 right-6 w-2 h-2 bg-[#00FFF7] rounded-full animate-pulse"></div>
              <div className="absolute bottom-8 left-16 w-2 h-2 bg-[#B400FF] rounded-full animate-pulse"></div>
            </div>
          </div>
        </div>

        {/* Feature cards */}
        <div className="w-full max-w-sm space-y-4 mb-12">
          <div className="glass-panel rounded-2xl p-4 flex items-center space-x-4 hover:neon-glow-cyan transition-all duration-200 cursor-pointer">
            <div className="w-12 h-12 rounded-full bg-[#00FFF7]/20 flex items-center justify-center">
              <MapPin className="w-6 h-6 text-[#00FFF7]" />
            </div>
            <div>
              <h3 className="font-medium">Drop AR Memories</h3>
              <p className="text-sm text-white/70">Leave digital traces in the real world</p>
            </div>
          </div>

          <div className="glass-panel rounded-2xl p-4 flex items-center space-x-4 hover:neon-glow-magenta transition-all duration-200 cursor-pointer">
            <div className="w-12 h-12 rounded-full bg-[#FF00A8]/20 flex items-center justify-center">
              <Users className="w-6 h-6 text-[#FF00A8]" />
            </div>
            <div>
              <h3 className="font-medium">Discover People Around You</h3>
              <p className="text-sm text-white/70">Connect with nearby adventurers</p>
            </div>
          </div>

          <div className="glass-panel rounded-2xl p-4 flex items-center space-x-4 hover:neon-glow-purple transition-all duration-200 cursor-pointer">
            <div className="w-12 h-12 rounded-full bg-[#B400FF]/20 flex items-center justify-center">
              <Trophy className="w-6 h-6 text-[#B400FF]" />
            </div>
            <div>
              <h3 className="font-medium">Join Scavenger Hunts</h3>
              <p className="text-sm text-white/70">Complete challenges and earn rewards</p>
            </div>
          </div>
        </div>

        {/* Get Started button */}
        <Button 
          onClick={onGetStarted}
          className="w-full max-w-sm h-14 rounded-2xl cyberpunk-gradient border-0 neon-glow-cyan text-black font-bold text-lg hover:scale-105 transition-transform duration-200"
        >
          Get Started
        </Button>
      </div>
    </div>
  );
}