import React, { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { User, Mail, Lock, Eye, EyeOff } from 'lucide-react';

interface LoginScreenProps {
  onLogin: () => void;
}

export function LoginScreen({ onLogin }: LoginScreenProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isSignUp, setIsSignUp] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onLogin();
  };

  return (
    <div className="min-h-screen dark-gradient-bg text-white flex items-center justify-center px-6">
      <div className="w-full max-w-sm">
        {/* Holographic Avatar */}
        <div className="flex justify-center mb-8">
          <div className="w-24 h-24 rounded-full glass-panel neon-glow-purple flex items-center justify-center">
            <User className="w-12 h-12 text-[#B400FF] animate-pulse" />
          </div>
        </div>

        {/* Welcome text */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold mb-2">
            {isSignUp ? 'Join ARound You' : 'Welcome Back'}
          </h1>
          <p className="text-white/70">
            {isSignUp ? 'Create your account to start exploring' : 'Sign in to continue your journey'}
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Email Input */}
          <div className="relative">
            <div className="glass-panel rounded-2xl p-4 flex items-center space-x-3">
              <Mail className="w-5 h-5 text-[#00FFF7]" />
              <Input
                type="email"
                placeholder="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="flex-1 bg-transparent border-0 text-white placeholder:text-white/50 focus:ring-0 p-0"
              />
            </div>
          </div>

          {/* Password Input */}
          <div className="relative">
            <div className="glass-panel rounded-2xl p-4 flex items-center space-x-3">
              <Lock className="w-5 h-5 text-[#FF00A8]" />
              <Input
                type={showPassword ? 'text' : 'password'}
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="flex-1 bg-transparent border-0 text-white placeholder:text-white/50 focus:ring-0 p-0"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="text-white/50 hover:text-white"
              >
                {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
          </div>

          {/* Submit Button */}
          <Button 
            type="submit"
            className="w-full h-14 rounded-2xl cyberpunk-gradient border-0 neon-glow-cyan text-black font-bold text-lg hover:scale-105 transition-transform duration-200"
          >
            {isSignUp ? 'Create Account' : 'Sign In'}
          </Button>
        </form>

        {/* Social Sign In */}
        <div className="mt-6 space-y-4">
          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-white/20"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-4 bg-transparent text-white/70">Or continue with</span>
            </div>
          </div>

          <div className="flex space-x-4">
            <Button 
              variant="outline" 
              className="flex-1 h-12 rounded-xl glass-panel border-white/20 text-white hover:neon-glow-cyan"
            >
              <svg className="w-5 h-5" viewBox="0 0 24 24">
                <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
              </svg>
            </Button>
            <Button 
              variant="outline" 
              className="flex-1 h-12 rounded-xl glass-panel border-white/20 text-white hover:neon-glow-magenta"
            >
              <svg className="w-5 h-5" viewBox="0 0 24 24">
                <path fill="currentColor" d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
            </Button>
          </div>
        </div>

        {/* Toggle Sign Up/Sign In */}
        <div className="mt-8 text-center">
          <p className="text-white/70">
            {isSignUp ? 'Already have an account?' : "Don't have an account?"}{' '}
            <button
              onClick={() => setIsSignUp(!isSignUp)}
              className="text-[#00FFF7] hover:text-[#FF00A8] transition-colors font-medium"
            >
              {isSignUp ? 'Sign In' : 'Sign Up'}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}