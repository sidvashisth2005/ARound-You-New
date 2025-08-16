import React, { useState } from 'react';
import { OnboardingScreen } from './components/OnboardingScreen';
import { LoginScreen } from './components/LoginScreen';
import { HomeMapScreen } from './components/HomeMapScreen';
import { ARMemoryScreen } from './components/ARMemoryScreen';
import { SocialDiscoveryScreen } from './components/SocialDiscoveryScreen';
import { ChatScreen } from './components/ChatScreen';
import { AchievementsScreen } from './components/AchievementsScreen';
import { ProfileScreen } from './components/ProfileScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { NotificationsScreen } from './components/NotificationsScreen';
import { HelpScreen } from './components/HelpScreen';
import { MemoryDetailsScreen } from './components/MemoryDetailsScreen';

type Screen = 'onboarding' | 'login' | 'home' | 'ar-memory' | 'social' | 'chat' | 'achievements' | 'profile' | 'settings' | 'notifications' | 'help' | 'memory-details' | 'privacy' | 'terms';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('onboarding');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [showDevNav, setShowDevNav] = useState(true); // Development navigation

  const navigateToScreen = (screen: Screen) => {
    setCurrentScreen(screen);
  };

  const handleLogin = () => {
    setIsAuthenticated(true);
    setCurrentScreen('home');
  };

  const handleGetStarted = () => {
    setCurrentScreen('login');
  };

  const renderScreen = () => {
    switch (currentScreen) {
      case 'onboarding':
        return <OnboardingScreen onGetStarted={handleGetStarted} />;
      case 'login':
        return <LoginScreen onLogin={handleLogin} />;
      case 'home':
        return <HomeMapScreen onNavigate={navigateToScreen} />;
      case 'ar-memory':
        return <ARMemoryScreen onBack={() => navigateToScreen('home')} />;
      case 'social':
        return <SocialDiscoveryScreen onBack={() => navigateToScreen('home')} onStartChat={() => navigateToScreen('chat')} />;
      case 'chat':
        return <ChatScreen onBack={() => navigateToScreen('social')} />;
      case 'achievements':
        return <AchievementsScreen onBack={() => navigateToScreen('home')} />;
      case 'profile':
        return <ProfileScreen onBack={() => navigateToScreen('home')} onNavigate={navigateToScreen} />;
      case 'settings':
        return <SettingsScreen onBack={() => navigateToScreen('profile')} onNavigate={navigateToScreen} />;
      case 'notifications':
        return <NotificationsScreen onBack={() => navigateToScreen('home')} onNavigate={navigateToScreen} />;
      case 'help':
        return <HelpScreen onBack={() => navigateToScreen('settings')} />;
      case 'memory-details':
        return <MemoryDetailsScreen onBack={() => navigateToScreen('home')} />;
      case 'privacy':
        return <HelpScreen onBack={() => navigateToScreen('settings')} />;
      case 'terms':
        return <HelpScreen onBack={() => navigateToScreen('settings')} />;
      default:
        return <OnboardingScreen onGetStarted={handleGetStarted} />;
    }
  };

  return (
    <div className="min-h-screen dark-gradient-bg overflow-hidden relative">
      {renderScreen()}
      
      {/* Development Navigation Bar */}
      {showDevNav && (
        <div className="fixed top-4 left-4 z-50">
          <div className="glass-panel rounded-lg p-2 flex flex-col space-y-1">
            <button 
              onClick={() => setShowDevNav(false)}
              className="text-xs text-white/50 hover:text-white mb-2 text-right"
            >
              Hide
            </button>
            <div className="grid grid-cols-2 gap-1 text-xs">
              <button
                onClick={() => navigateToScreen('onboarding')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'onboarding' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Onboard
              </button>
              <button
                onClick={() => navigateToScreen('login')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'login' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Login
              </button>
              <button
                onClick={() => {
                  setIsAuthenticated(true);
                  navigateToScreen('home');
                }}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'home' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Home
              </button>
              <button
                onClick={() => navigateToScreen('ar-memory')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'ar-memory' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                AR
              </button>
              <button
                onClick={() => navigateToScreen('social')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'social' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Social
              </button>
              <button
                onClick={() => navigateToScreen('chat')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'chat' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Chat
              </button>
              <button
                onClick={() => navigateToScreen('achievements')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'achievements' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Achievements
              </button>
              <button
                onClick={() => navigateToScreen('profile')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'profile' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Profile
              </button>
              <button
                onClick={() => navigateToScreen('settings')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'settings' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Settings
              </button>
              <button
                onClick={() => navigateToScreen('notifications')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'notifications' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Notifications
              </button>
              <button
                onClick={() => navigateToScreen('help')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'help' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Help
              </button>
              <button
                onClick={() => navigateToScreen('memory-details')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'memory-details' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Memory Details
              </button>
              <button
                onClick={() => navigateToScreen('privacy')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'privacy' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Privacy
              </button>
              <button
                onClick={() => navigateToScreen('terms')}
                className={`px-2 py-1 rounded text-xs ${
                  currentScreen === 'terms' 
                    ? 'bg-[#00FFF7] text-black' 
                    : 'text-white/70 hover:text-white hover:bg-white/10'
                }`}
              >
                Terms
              </button>
            </div>
          </div>
        </div>
      )}
      
      {/* Show dev nav toggle when hidden */}
      {!showDevNav && (
        <button
          onClick={() => setShowDevNav(true)}
          className="fixed top-4 left-4 z-50 w-8 h-8 glass-panel rounded-full text-[#00FFF7] hover:neon-glow-cyan"
        >
          ≡
        </button>
      )}
    </div>
  );
}