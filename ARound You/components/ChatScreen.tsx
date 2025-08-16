import React, { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Avatar, AvatarFallback } from './ui/avatar';
import { ArrowLeft, Send, Smile, Paperclip, Mic } from 'lucide-react';

interface ChatScreenProps {
  onBack: () => void;
}

interface Message {
  id: number;
  text: string;
  isOwn: boolean;
  timestamp: string;
  type: 'text' | 'image' | 'audio';
}

export function ChatScreen({ onBack }: ChatScreenProps) {
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<Message[]>([
    {
      id: 1,
      text: "Hey! I saw you dropped an AR memory near the coffee shop ☕",
      isOwn: false,
      timestamp: "2:30 PM",
      type: 'text'
    },
    {
      id: 2,
      text: "Yeah! It's a photo of the amazing latte art they make there",
      isOwn: true,
      timestamp: "2:31 PM",
      type: 'text'
    },
    {
      id: 3,
      text: "That's so cool! I love finding hidden gems through AR memories",
      isOwn: false,
      timestamp: "2:32 PM",
      type: 'text'
    },
    {
      id: 4,
      text: "Want to meet up there later? I'm doing a scavenger hunt nearby",
      isOwn: true,
      timestamp: "2:33 PM",
      type: 'text'
    },
    {
      id: 5,
      text: "Absolutely! What time works for you?",
      isOwn: false,
      timestamp: "2:34 PM",
      type: 'text'
    }
  ]);

  const handleSendMessage = () => {
    if (message.trim()) {
      const newMessage: Message = {
        id: messages.length + 1,
        text: message,
        isOwn: true,
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        type: 'text'
      };
      setMessages([...messages, newMessage]);
      setMessage('');
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSendMessage();
    }
  };

  return (
    <div className="min-h-screen dark-gradient-bg text-white flex flex-col">
      {/* Header */}
      <div className="flex items-center p-4 glass-panel">
        <Button
          onClick={onBack}
          variant="ghost"
          className="w-10 h-10 rounded-full mr-3 text-white hover:neon-glow-cyan"
        >
          <ArrowLeft className="w-5 h-5" />
        </Button>
        
        <Avatar className="w-10 h-10 mr-3 neon-glow-cyan">
          <AvatarFallback className="bg-[#00FFF7] text-black">
            AC
          </AvatarFallback>
        </Avatar>
        
        <div className="flex-1">
          <h2 className="font-medium">Alex Chen</h2>
          <p className="text-sm text-white/70">~50m away • Online</p>
        </div>
        
        <div className="w-3 h-3 rounded-full bg-green-400 neon-glow-cyan"></div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex ${msg.isOwn ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-xs lg:max-w-md px-4 py-3 rounded-2xl ${
                msg.isOwn
                  ? 'cyberpunk-gradient text-black neon-glow-cyan ml-12'
                  : 'glass-panel border-[#FF00A8]/30 neon-glow-magenta mr-12'
              }`}
            >
              <p className="text-sm leading-relaxed">{msg.text}</p>
              <p 
                className={`text-xs mt-1 ${
                  msg.isOwn ? 'text-black/70' : 'text-white/50'
                }`}
              >
                {msg.timestamp}
              </p>
            </div>
          </div>
        ))}
      </div>

      {/* Input Area */}
      <div className="p-4">
        <div className="glass-panel rounded-2xl p-3 flex items-center space-x-3">
          <Button
            variant="ghost"
            className="w-8 h-8 rounded-full text-[#B400FF] hover:neon-glow-purple"
          >
            <Paperclip className="w-4 h-4" />
          </Button>
          
          <Input
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Type a message..."
            className="flex-1 bg-transparent border-0 text-white placeholder:text-white/50 focus:ring-0 p-0"
          />
          
          <Button
            variant="ghost"
            className="w-8 h-8 rounded-full text-[#FFD700] hover:text-[#FFD700]/80"
          >
            <Smile className="w-4 h-4" />
          </Button>
          
          <Button
            variant="ghost"
            className="w-8 h-8 rounded-full text-[#FF00A8] hover:neon-glow-magenta"
          >
            <Mic className="w-4 h-4" />
          </Button>
          
          <Button
            onClick={handleSendMessage}
            disabled={!message.trim()}
            className="w-10 h-10 rounded-full cyberpunk-gradient border-0 neon-glow-cyan disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Send className="w-4 h-4 text-black" />
          </Button>
        </div>
      </div>

      {/* Floating AR suggestion */}
      <div className="absolute top-1/2 right-4 transform -translate-y-1/2">
        <div className="glass-panel rounded-lg p-3 max-w-xs">
          <p className="text-xs text-white/70 mb-2">💡 AR Tip</p>
          <p className="text-sm">Share your current AR view with Alex!</p>
          <Button className="w-full mt-2 h-8 rounded-lg bg-[#B400FF]/20 border border-[#B400FF]/30 text-[#B400FF] hover:neon-glow-purple">
            Share AR View
          </Button>
        </div>
      </div>
    </div>
  );
}