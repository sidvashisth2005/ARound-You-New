import React, { useState } from 'react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { 
  ArrowLeft, 
  Bell, 
  Users, 
  MapPin, 
  Trophy, 
  Heart, 
  MessageCircle, 
  Gift,
  AlertCircle,
  Check,
  MoreVertical
} from 'lucide-react';

interface NotificationsScreenProps {
  onBack: () => void;
  onNavigate: (screen: string) => void;
}

export function NotificationsScreen({ onBack, onNavigate }: NotificationsScreenProps) {
  const [notifications] = useState([
    {
      id: 1,
      type: 'social',
      title: 'New Friend Request',
      message: 'Alex wants to connect with you',
      time: '2 min ago',
      read: false,
      icon: Users,
      color: '#00FFF7'
    },
    {
      id: 2,
      type: 'memory',
      title: 'Memory Discovered',
      message: 'Someone found your AR memory at Central Park',
      time: '15 min ago',
      read: false,
      icon: MapPin,
      color: '#FFD700'
    },
    {
      id: 3,
      type: 'achievement',
      title: 'Achievement Unlocked!',
      message: 'You earned the "Explorer" badge',
      time: '1 hour ago',
      read: true,
      icon: Trophy,
      color: '#B400FF'
    },
    {
      id: 4,
      type: 'like',
      title: 'Memory Liked',
      message: 'Sam liked your AR memory',
      time: '2 hours ago',
      read: true,
      icon: Heart,
      color: '#FF00A8'
    },
    {
      id: 5,
      type: 'message',
      title: 'New Message',
      message: 'Riley: "Great spot for memories!"',
      time: '3 hours ago',
      read: true,
      icon: MessageCircle,
      color: '#00FFF7'
    },
    {
      id: 6,
      type: 'hunt',
      title: 'Scavenger Hunt Update',
      message: 'New clue available in downtown area',
      time: '5 hours ago',
      read: true,
      icon: Gift,
      color: '#FFD700'
    },
    {
      id: 7,
      type: 'system',
      title: 'App Update Available',
      message: 'Version 2.1.0 with new AR features',
      time: '1 day ago',
      read: true,
      icon: AlertCircle,
      color: '#B400FF'
    }
  ]);

  const [filter, setFilter] = useState('all');

  const filteredNotifications = notifications.filter(notif => {
    if (filter === 'all') return true;
    if (filter === 'unread') return !notif.read;
    return notif.type === filter;
  });

  const unreadCount = notifications.filter(n => !n.read).length;

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
          <div className="flex items-center space-x-2">
            <h1 className="text-lg font-medium">Notifications</h1>
            {unreadCount > 0 && (
              <Badge className="bg-[#FF00A8] text-black px-2 py-0.5 text-xs">
                {unreadCount}
              </Badge>
            )}
          </div>
          <Button
            variant="ghost"
            size="icon"
            className="w-10 h-10 rounded-full glass-panel border-white/20 hover:neon-glow-cyan"
          >
            <MoreVertical className="w-4 h-4 text-white" />
          </Button>
        </div>
      </div>

      {/* Filter Tabs */}
      <div className="pt-20 px-4">
        <div className="flex space-x-2 mb-6 overflow-x-auto">
          {[
            { key: 'all', label: 'All' },
            { key: 'unread', label: 'Unread' },
            { key: 'social', label: 'Social' },
            { key: 'memory', label: 'Memories' },
            { key: 'achievement', label: 'Achievements' }
          ].map((tab) => (
            <Button
              key={tab.key}
              variant={filter === tab.key ? "default" : "ghost"}
              size="sm"
              onClick={() => setFilter(tab.key)}
              className={`rounded-full px-4 whitespace-nowrap ${
                filter === tab.key 
                  ? 'cyberpunk-gradient text-black' 
                  : 'glass-panel border-white/20 text-white hover:neon-glow-cyan'
              }`}
            >
              {tab.label}
            </Button>
          ))}
        </div>
      </div>

      {/* Notifications List */}
      <div className="px-4 pb-8 space-y-3">
        {filteredNotifications.length === 0 ? (
          <div className="glass-panel rounded-2xl p-8 text-center">
            <Bell className="w-12 h-12 text-white/50 mx-auto mb-4" />
            <h3 className="text-lg font-medium mb-2">No notifications</h3>
            <p className="text-white/70">You're all caught up!</p>
          </div>
        ) : (
          filteredNotifications.map((notification) => (
            <div
              key={notification.id}
              className={`glass-panel rounded-2xl p-4 cursor-pointer transition-all duration-200 ${
                !notification.read 
                  ? 'border-l-4 border-l-[#00FFF7] hover:neon-glow-cyan' 
                  : 'hover:bg-white/5'
              }`}
              onClick={() => {
                // Handle notification click based on type
                if (notification.type === 'social') {
                  onNavigate('social');
                } else if (notification.type === 'message') {
                  onNavigate('chat');
                } else if (notification.type === 'achievement') {
                  onNavigate('achievements');
                }
              }}
            >
              <div className="flex items-start space-x-3">
                <div 
                  className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
                  style={{ 
                    backgroundColor: `${notification.color}20`,
                    border: `1px solid ${notification.color}40`
                  }}
                >
                  <notification.icon 
                    className="w-5 h-5" 
                    style={{ color: notification.color }}
                  />
                </div>
                
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-1">
                    <h4 className={`font-medium ${!notification.read ? 'text-white' : 'text-white/90'}`}>
                      {notification.title}
                    </h4>
                    <span className="text-xs text-white/50">{notification.time}</span>
                  </div>
                  <p className={`text-sm ${!notification.read ? 'text-white/90' : 'text-white/70'}`}>
                    {notification.message}
                  </p>
                </div>

                {!notification.read && (
                  <div className="w-2 h-2 bg-[#00FFF7] rounded-full flex-shrink-0 mt-2"></div>
                )}
              </div>
            </div>
          ))
        )}
      </div>

      {/* Quick Actions */}
      {unreadCount > 0 && (
        <div className="fixed bottom-4 left-4 right-4">
          <Button 
            className="w-full h-12 rounded-2xl cyberpunk-gradient border-0 neon-glow-cyan text-black font-medium"
          >
            <Check className="w-4 h-4 mr-2" />
            Mark All as Read
          </Button>
        </div>
      )}
    </div>
  );
}