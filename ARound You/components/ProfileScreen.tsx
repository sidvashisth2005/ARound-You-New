import React, { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Badge } from './ui/badge';
import { Switch } from './ui/switch';
import { 
  ArrowLeft, 
  User, 
  MapPin, 
  Trophy, 
  Settings, 
  Bell,
  Shield,
  Eye,
  Camera,
  Edit3,
  Star,
  Zap,
  Globe
} from 'lucide-react';

interface ProfileScreenProps {
  onBack: () => void;
  onNavigate?: (screen: string) => void;
}

export function ProfileScreen({ onBack, onNavigate }: ProfileScreenProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [username, setUsername] = useState('CyberExplorer');
  const [bio, setBio] = useState('AR enthusiast exploring the digital frontier 🌐✨');

  const [stats] = useState({
    memoriesDropped: 47,
    friendsFound: 23,
    achievementsUnlocked: 15,
    streakDays: 12
  });

  const [achievements] = useState([
    { id: 1, name: 'First Drop', description: 'Dropped your first AR memory', color: '#00FFF7', earned: true },
    { id: 2, name: 'Social Butterfly', description: 'Connected with 10+ users', color: '#FF00A8', earned: true },
    { id: 3, name: 'Explorer', description: 'Visited 25+ locations', color: '#FFD700', earned: true },
    { id: 4, name: 'Legend', description: 'Reached level 10', color: '#B400FF', earned: false },
  ]);

  const [privacy, setPrivacy] = useState({
    shareLocation: true,
    showOnline: true,
    allowMessages: true,
    visibleProfile: true
  });

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
          <h1 className="text-lg font-medium">Profile</h1>
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setIsEditing(!isEditing)}
            className="w-10 h-10 rounded-full glass-panel border-white/20 hover:neon-glow-cyan"
          >
            <Edit3 className="w-4 h-4 text-[#00FFF7]" />
          </Button>
        </div>
      </div>

      {/* Content */}
      <div className="pt-20 px-4 pb-4 space-y-6">
        {/* Profile Info */}
        <div className="text-center">
          <div className="relative inline-block mb-4">
            <Avatar className="w-24 h-24 neon-glow-cyan">
              <AvatarImage src="" />
              <AvatarFallback className="bg-[#00FFF7]/20 text-[#00FFF7] text-2xl">
                {username.slice(0, 2).toUpperCase()}
              </AvatarFallback>
            </Avatar>
            {isEditing && (
              <button className="absolute bottom-0 right-0 w-8 h-8 rounded-full bg-[#00FFF7] text-black flex items-center justify-center hover:scale-110 transition-transform">
                <Camera className="w-4 h-4" />
              </button>
            )}
          </div>
          
          {isEditing ? (
            <div className="space-y-2 max-w-xs mx-auto">
              <Input
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="text-center bg-white/10 border-white/20 text-white"
              />
              <Input
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                className="text-center bg-white/10 border-white/20 text-white text-sm"
              />
            </div>
          ) : (
            <div>
              <h2 className="text-xl font-medium mb-1">{username}</h2>
              <p className="text-white/70 text-sm">{bio}</p>
            </div>
          )}

          {/* Level Badge */}
          <div className="flex items-center justify-center mt-3">
            <Badge className="bg-gradient-to-r from-[#00FFF7] to-[#B400FF] text-black px-4 py-1">
              <Zap className="w-3 h-3 mr-1" />
              Level 7 Explorer
            </Badge>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-4">
          <div className="glass-panel rounded-2xl p-4 text-center">
            <div className="text-2xl font-medium text-[#00FFF7] mb-1">{stats.memoriesDropped}</div>
            <div className="text-sm text-white/70">Memories</div>
          </div>
          <div className="glass-panel rounded-2xl p-4 text-center">
            <div className="text-2xl font-medium text-[#FF00A8] mb-1">{stats.friendsFound}</div>
            <div className="text-sm text-white/70">Friends</div>
          </div>
          <div className="glass-panel rounded-2xl p-4 text-center">
            <div className="text-2xl font-medium text-[#FFD700] mb-1">{stats.achievementsUnlocked}</div>
            <div className="text-sm text-white/70">Achievements</div>
          </div>
          <div className="glass-panel rounded-2xl p-4 text-center">
            <div className="text-2xl font-medium text-[#B400FF] mb-1">{stats.streakDays}</div>
            <div className="text-sm text-white/70">Day Streak</div>
          </div>
        </div>

        {/* Recent Achievements */}
        <div className="glass-panel rounded-2xl p-4">
          <h3 className="text-sm font-medium mb-3 flex items-center">
            <Trophy className="w-4 h-4 mr-2 text-[#FFD700]" />
            Recent Achievements
          </h3>
          <div className="space-y-3">
            {achievements.slice(0, 3).map((achievement) => (
              <div key={achievement.id} className="flex items-center space-x-3">
                <div 
                  className="w-8 h-8 rounded-full flex items-center justify-center"
                  style={{ 
                    backgroundColor: achievement.earned ? `${achievement.color}20` : 'rgba(255,255,255,0.1)',
                    border: `1px solid ${achievement.earned ? achievement.color : 'rgba(255,255,255,0.2)'}`
                  }}
                >
                  <Trophy 
                    className="w-4 h-4" 
                    style={{ color: achievement.earned ? achievement.color : 'rgba(255,255,255,0.5)' }}
                  />
                </div>
                <div className="flex-1">
                  <div className={`text-sm font-medium ${achievement.earned ? 'text-white' : 'text-white/50'}`}>
                    {achievement.name}
                  </div>
                  <div className="text-xs text-white/50">{achievement.description}</div>
                </div>
                {achievement.earned && (
                  <Star className="w-4 h-4 text-[#FFD700]" />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Privacy Settings */}
        <div className="glass-panel rounded-2xl p-4">
          <h3 className="text-sm font-medium mb-4 flex items-center">
            <Shield className="w-4 h-4 mr-2 text-[#B400FF]" />
            Privacy Settings
          </h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <MapPin className="w-4 h-4 text-[#00FFF7]" />
                <div>
                  <div className="text-sm">Share Location</div>
                  <div className="text-xs text-white/50">Allow others to see your location</div>
                </div>
              </div>
              <Switch 
                checked={privacy.shareLocation}
                onCheckedChange={(checked) => setPrivacy({...privacy, shareLocation: checked})}
              />
            </div>
            
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <Globe className="w-4 h-4 text-[#FF00A8]" />
                <div>
                  <div className="text-sm">Show Online Status</div>
                  <div className="text-xs text-white/50">Display when you're active</div>
                </div>
              </div>
              <Switch 
                checked={privacy.showOnline}
                onCheckedChange={(checked) => setPrivacy({...privacy, showOnline: checked})}
              />
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <Bell className="w-4 h-4 text-[#FFD700]" />
                <div>
                  <div className="text-sm">Allow Messages</div>
                  <div className="text-xs text-white/50">Receive messages from other users</div>
                </div>
              </div>
              <Switch 
                checked={privacy.allowMessages}
                onCheckedChange={(checked) => setPrivacy({...privacy, allowMessages: checked})}
              />
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <Eye className="w-4 h-4 text-[#B400FF]" />
                <div>
                  <div className="text-sm">Public Profile</div>
                  <div className="text-xs text-white/50">Make your profile discoverable</div>
                </div>
              </div>
              <Switch 
                checked={privacy.visibleProfile}
                onCheckedChange={(checked) => setPrivacy({...privacy, visibleProfile: checked})}
              />
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3 pb-4">
          {isEditing && (
            <Button 
              onClick={() => setIsEditing(false)}
              className="w-full h-12 rounded-2xl cyberpunk-gradient border-0 neon-glow-cyan text-black font-medium"
            >
              Save Changes
            </Button>
          )}
          
          <Button 
            variant="outline"
            className="w-full h-12 rounded-2xl glass-panel border-white/20 text-white hover:neon-glow-purple"
            onClick={() => onNavigate && onNavigate('settings')}
          >
            <Settings className="w-4 h-4 mr-2" />
            Advanced Settings
          </Button>
        </div>
      </div>
    </div>
  );
}