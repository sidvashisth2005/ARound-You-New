import React, { useState } from 'react';
import { Button } from './ui/button';
import { Switch } from './ui/switch';
import { Slider } from './ui/slider';
import { 
  ArrowLeft, 
  Bell, 
  MapPin, 
  Eye, 
  Volume2, 
  Vibrate, 
  Moon, 
  Globe, 
  Shield, 
  HelpCircle,
  Info,
  LogOut,
  Trash2,
  Download,
  Upload
} from 'lucide-react';

interface SettingsScreenProps {
  onBack: () => void;
  onNavigate: (screen: string) => void;
}

export function SettingsScreen({ onBack, onNavigate }: SettingsScreenProps) {
  const [settings, setSettings] = useState({
    notifications: true,
    locationServices: true,
    darkMode: true,
    soundEffects: true,
    hapticFeedback: true,
    autoSave: true,
    dataSync: true,
    publicProfile: true
  });

  const [volumes, setVolumes] = useState({
    master: [75],
    effects: [60],
    notifications: [80]
  });

  const updateSetting = (key: string, value: boolean) => {
    setSettings(prev => ({ ...prev, [key]: value }));
  };

  return (
    <div className="min-h-screen dark-gradient-bg text-white relative overflow-hidden">
      {/* Header */}
      <div className="absolute top-0 left-0 right-0 z-20 p-4">
        <div className="flex items-center justify-between">
          <Button
            variant="ghost"
            size="icon"
            onClick={onBack}
            className="w-10 h-10 rounded-full glass-panel border-white/20 hover:neon-glow-cyan"
          >
            <ArrowLeft className="w-5 h-5 text-[#00FFF7]" />
          </Button>
          <h1 className="text-lg font-medium">Settings</h1>
          <div className="w-10" /> {/* Spacer */}
        </div>
      </div>

      {/* Content */}
      <div className="pt-20 px-4 pb-8 space-y-6">
        {/* Notifications */}
        <div className="glass-panel rounded-2xl p-4">
          <h3 className="text-sm font-medium mb-4 flex items-center">
            <Bell className="w-4 h-4 mr-2 text-[#00FFF7]" />
            Notifications
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm">Push Notifications</div>
                <div className="text-xs text-white/50">Receive app notifications</div>
              </div>
              <Switch 
                checked={settings.notifications}
                onCheckedChange={(checked) => updateSetting('notifications', checked)}
              />
            </div>
            
            <div className="space-y-2">
              <div className="text-sm">Notification Volume</div>
              <Slider
                value={volumes.notifications}
                onValueChange={(value) => setVolumes({...volumes, notifications: value})}
                max={100}
                step={1}
                className="w-full"
              />
            </div>
          </div>
        </div>

        {/* Privacy & Location */}
        <div className="glass-panel rounded-2xl p-4">
          <h3 className="text-sm font-medium mb-4 flex items-center">
            <Shield className="w-4 h-4 mr-2 text-[#B400FF]" />
            Privacy & Location
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm">Location Services</div>
                <div className="text-xs text-white/50">Allow location access for AR features</div>
              </div>
              <Switch 
                checked={settings.locationServices}
                onCheckedChange={(checked) => updateSetting('locationServices', checked)}
              />
            </div>
            
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm">Public Profile</div>
                <div className="text-xs text-white/50">Make your profile discoverable</div>
              </div>
              <Switch 
                checked={settings.publicProfile}
                onCheckedChange={(checked) => updateSetting('publicProfile', checked)}
              />
            </div>
          </div>
        </div>

        {/* Audio & Feedback */}
        <div className="glass-panel rounded-2xl p-4">
          <h3 className="text-sm font-medium mb-4 flex items-center">
            <Volume2 className="w-4 h-4 mr-2 text-[#FF00A8]" />
            Audio & Feedback
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm">Sound Effects</div>
                <div className="text-xs text-white/50">AR interaction sounds</div>
              </div>
              <Switch 
                checked={settings.soundEffects}
                onCheckedChange={(checked) => updateSetting('soundEffects', checked)}
              />
            </div>
            
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm">Haptic Feedback</div>
                <div className="text-xs text-white/50">Vibrations for interactions</div>
              </div>
              <Switch 
                checked={settings.hapticFeedback}
                onCheckedChange={(checked) => updateSetting('hapticFeedback', checked)}
              />
            </div>

            <div className="space-y-2">
              <div className="text-sm">Master Volume</div>
              <Slider
                value={volumes.master}
                onValueChange={(value) => setVolumes({...volumes, master: value})}
                max={100}
                step={1}
                className="w-full"
              />
            </div>

            <div className="space-y-2">
              <div className="text-sm">Effects Volume</div>
              <Slider
                value={volumes.effects}
                onValueChange={(value) => setVolumes({...volumes, effects: value})}
                max={100}
                step={1}
                className="w-full"
              />
            </div>
          </div>
        </div>

        {/* Data & Storage */}
        <div className="glass-panel rounded-2xl p-4">
          <h3 className="text-sm font-medium mb-4 flex items-center">
            <Globe className="w-4 h-4 mr-2 text-[#FFD700]" />
            Data & Storage
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm">Auto-Save Memories</div>
                <div className="text-xs text-white/50">Automatically save AR memories</div>
              </div>
              <Switch 
                checked={settings.autoSave}
                onCheckedChange={(checked) => updateSetting('autoSave', checked)}
              />
            </div>
            
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm">Cloud Sync</div>
                <div className="text-xs text-white/50">Sync data across devices</div>
              </div>
              <Switch 
                checked={settings.dataSync}
                onCheckedChange={(checked) => updateSetting('dataSync', checked)}
              />
            </div>

            <Button 
              variant="outline"
              className="w-full h-12 rounded-xl glass-panel border-white/20 text-white hover:neon-glow-cyan"
            >
              <Download className="w-4 h-4 mr-2" />
              Export Data
            </Button>
            
            <Button 
              variant="outline"
              className="w-full h-12 rounded-xl glass-panel border-white/20 text-white hover:neon-glow-cyan"
            >
              <Upload className="w-4 h-4 mr-2" />
              Import Data
            </Button>
          </div>
        </div>

        {/* Support & Info */}
        <div className="glass-panel rounded-2xl p-4">
          <h3 className="text-sm font-medium mb-4 flex items-center">
            <HelpCircle className="w-4 h-4 mr-2 text-[#00FFF7]" />
            Support & Info
          </h3>
          <div className="space-y-3">
            <Button 
              variant="ghost"
              className="w-full justify-start h-12 text-white hover:bg-white/10"
              onClick={() => onNavigate('help')}
            >
              <HelpCircle className="w-4 h-4 mr-3" />
              Help & Support
            </Button>
            
            <Button 
              variant="ghost"
              className="w-full justify-start h-12 text-white hover:bg-white/10"
              onClick={() => onNavigate('privacy')}
            >
              <Shield className="w-4 h-4 mr-3" />
              Privacy Policy
            </Button>
            
            <Button 
              variant="ghost"
              className="w-full justify-start h-12 text-white hover:bg-white/10"
              onClick={() => onNavigate('terms')}
            >
              <Info className="w-4 h-4 mr-3" />
              Terms of Service
            </Button>
          </div>
        </div>

        {/* Account Actions */}
        <div className="space-y-3">
          <Button 
            variant="outline"
            className="w-full h-12 rounded-xl glass-panel border-red-500/50 text-red-400 hover:bg-red-500/20"
          >
            <LogOut className="w-4 h-4 mr-2" />
            Sign Out
          </Button>
          
          <Button 
            variant="outline"
            className="w-full h-12 rounded-xl glass-panel border-red-500/50 text-red-400 hover:bg-red-500/20"
          >
            <Trash2 className="w-4 h-4 mr-2" />
            Delete Account
          </Button>
        </div>
      </div>
    </div>
  );
}