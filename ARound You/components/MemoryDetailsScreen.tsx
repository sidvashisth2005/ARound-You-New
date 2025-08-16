import React, { useState } from 'react';
import { Button } from './ui/button';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Badge } from './ui/badge';
import { 
  ArrowLeft, 
  Heart, 
  MessageCircle, 
  Share, 
  MapPin, 
  Calendar, 
  Eye, 
  Flag,
  MoreVertical,
  Play,
  Volume2,
  VolumeX
} from 'lucide-react';

interface MemoryDetailsScreenProps {
  onBack: () => void;
  memoryId?: string;
}

export function MemoryDetailsScreen({ onBack, memoryId }: MemoryDetailsScreenProps) {
  const [isLiked, setIsLiked] = useState(false);
  const [likes, setLikes] = useState(42);
  const [isMuted, setIsMuted] = useState(false);

  // Mock memory data
  const memory = {
    id: memoryId || '1',
    type: 'photo',
    title: 'Sunset at the Bridge',
    description: 'Caught this amazing sunset view from the bridge today. The AR overlay shows the city skyline evolution over the years!',
    creator: {
      name: 'Alex Chen',
      avatar: '',
      level: 15
    },
    location: 'Golden Gate Bridge, SF',
    timestamp: '2 hours ago',
    views: 156,
    likes: 42,
    comments: 8,
    tags: ['sunset', 'bridge', 'cityscape', 'AR'],
    media: {
      thumbnail: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=600&fit=crop',
      duration: null // null for photo, duration in seconds for video/audio
    }
  };

  const comments = [
    {
      id: 1,
      user: 'Sam Rivera',
      avatar: '',
      comment: 'Incredible shot! I was there yesterday and missed this view completely.',
      time: '1 hour ago'
    },
    {
      id: 2,
      user: 'Riley Park',
      avatar: '',
      comment: 'The AR historical overlay is so cool! 🔥',
      time: '45 min ago'
    },
    {
      id: 3,
      user: 'Jordan Kim',
      avatar: '',
      comment: 'This spot is definitely going on my must-visit list',
      time: '30 min ago'
    }
  ];

  const handleLike = () => {
    setIsLiked(!isLiked);
    setLikes(prev => isLiked ? prev - 1 : prev + 1);
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
          <h1 className="text-sm font-medium">AR Memory</h1>
          <Button
            variant="ghost"
            size="icon"
            className="w-10 h-10 rounded-full glass-panel border-white/20 hover:neon-glow-cyan"
          >
            <MoreVertical className="w-4 h-4 text-white" />
          </Button>
        </div>
      </div>

      {/* Content */}
      <div className="pt-16">
        {/* Media Container */}
        <div className="relative aspect-[3/4] mx-4 mb-4 rounded-2xl overflow-hidden glass-panel">
          <img
            src={memory.media.thumbnail}
            alt={memory.title}
            className="w-full h-full object-cover"
          />
          
          {/* Media Type Indicator */}
          {memory.type === 'video' && (
            <div className="absolute inset-0 flex items-center justify-center">
              <Button
                size="icon"
                className="w-16 h-16 rounded-full bg-black/50 backdrop-blur-sm border-2 border-white/30 hover:scale-110 transition-transform"
              >
                <Play className="w-8 h-8 text-white fill-white" />
              </Button>
            </div>
          )}
          
          {memory.type === 'audio' && (
            <div className="absolute inset-0 bg-gradient-to-br from-[#00FFF7]/20 to-[#B400FF]/20 flex items-center justify-center">
              <div className="text-center">
                <Volume2 className="w-16 h-16 text-white mx-auto mb-4" />
                <p className="text-white/70">Audio Memory</p>
              </div>
            </div>
          )}

          {/* Audio Controls for audio type */}
          {memory.type === 'audio' && (
            <div className="absolute bottom-4 left-4 right-4">
              <div className="glass-panel rounded-xl p-3 flex items-center space-x-3">
                <Button size="icon" className="w-8 h-8 rounded-full cyberpunk-gradient">
                  <Play className="w-4 h-4 text-black" />
                </Button>
                <div className="flex-1 h-1 bg-white/20 rounded-full">
                  <div className="h-full w-1/3 bg-[#00FFF7] rounded-full"></div>
                </div>
                <Button 
                  size="icon" 
                  variant="ghost"
                  onClick={() => setIsMuted(!isMuted)}
                  className="w-8 h-8"
                >
                  {isMuted ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4" />}
                </Button>
              </div>
            </div>
          )}

          {/* AR Indicator */}
          <div className="absolute top-4 left-4">
            <Badge className="bg-[#00FFF7]/20 text-[#00FFF7] border border-[#00FFF7]/50">
              AR Memory
            </Badge>
          </div>

          {/* Stats */}
          <div className="absolute top-4 right-4 flex items-center space-x-2">
            <div className="glass-panel rounded-full px-2 py-1 flex items-center space-x-1">
              <Eye className="w-3 h-3" />
              <span className="text-xs">{memory.views}</span>
            </div>
          </div>
        </div>

        {/* Memory Info */}
        <div className="px-4 space-y-4">
          {/* Creator Info */}
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <Avatar className="w-10 h-10 neon-glow-cyan">
                <AvatarImage src={memory.creator.avatar} />
                <AvatarFallback className="bg-[#00FFF7]/20 text-[#00FFF7]">
                  {memory.creator.name.split(' ').map(n => n[0]).join('')}
                </AvatarFallback>
              </Avatar>
              <div>
                <div className="font-medium">{memory.creator.name}</div>
                <div className="text-xs text-white/70">Level {memory.creator.level} Explorer</div>
              </div>
            </div>
            <Button variant="outline" size="sm" className="rounded-full border-[#00FFF7]/50 text-[#00FFF7] hover:bg-[#00FFF7]/20">
              Follow
            </Button>
          </div>

          {/* Title and Description */}
          <div>
            <h2 className="text-lg font-medium mb-2">{memory.title}</h2>
            <p className="text-white/80 text-sm leading-relaxed">{memory.description}</p>
          </div>

          {/* Tags */}
          <div className="flex flex-wrap gap-2">
            {memory.tags.map((tag) => (
              <Badge 
                key={tag} 
                variant="outline" 
                className="rounded-full border-white/30 text-white/70 hover:bg-white/10"
              >
                #{tag}
              </Badge>
            ))}
          </div>

          {/* Location and Time */}
          <div className="flex items-center justify-between text-sm text-white/70">
            <div className="flex items-center space-x-1">
              <MapPin className="w-4 h-4" />
              <span>{memory.location}</span>
            </div>
            <div className="flex items-center space-x-1">
              <Calendar className="w-4 h-4" />
              <span>{memory.timestamp}</span>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex items-center justify-between py-4">
            <div className="flex items-center space-x-6">
              <Button
                variant="ghost"
                size="sm"
                onClick={handleLike}
                className={`flex items-center space-x-2 ${isLiked ? 'text-[#FF00A8]' : 'text-white/70'}`}
              >
                <Heart className={`w-5 h-5 ${isLiked ? 'fill-current' : ''}`} />
                <span>{likes}</span>
              </Button>
              
              <Button variant="ghost" size="sm" className="flex items-center space-x-2 text-white/70">
                <MessageCircle className="w-5 h-5" />
                <span>{memory.comments}</span>
              </Button>
            </div>

            <div className="flex items-center space-x-2">
              <Button size="icon" variant="ghost" className="w-8 h-8 rounded-full text-white/70 hover:text-white">
                <Share className="w-4 h-4" />
              </Button>
              <Button size="icon" variant="ghost" className="w-8 h-8 rounded-full text-white/70 hover:text-white">
                <Flag className="w-4 h-4" />
              </Button>
            </div>
          </div>

          {/* Comments Section */}
          <div className="glass-panel rounded-2xl p-4">
            <h3 className="font-medium mb-4">Comments ({memory.comments})</h3>
            <div className="space-y-4">
              {comments.map((comment) => (
                <div key={comment.id} className="flex space-x-3">
                  <Avatar className="w-8 h-8">
                    <AvatarImage src={comment.avatar} />
                    <AvatarFallback className="bg-white/10 text-white text-xs">
                      {comment.user.split(' ').map(n => n[0]).join('')}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-1">
                      <span className="text-sm font-medium">{comment.user}</span>
                      <span className="text-xs text-white/50">{comment.time}</span>
                    </div>
                    <p className="text-sm text-white/80">{comment.comment}</p>
                  </div>
                </div>
              ))}
            </div>
            
            {/* Add Comment */}
            <div className="mt-4 pt-4 border-t border-white/10">
              <div className="flex space-x-3">
                <Avatar className="w-8 h-8">
                  <AvatarFallback className="bg-[#00FFF7]/20 text-[#00FFF7] text-xs">
                    You
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1">
                  <input
                    type="text"
                    placeholder="Add a comment..."
                    className="w-full bg-white/5 border border-white/20 rounded-lg px-3 py-2 text-sm text-white placeholder:text-white/50 focus:outline-none focus:border-[#00FFF7]/50"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}