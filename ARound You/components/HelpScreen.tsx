import React, { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Textarea } from './ui/textarea';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from './ui/accordion';
import { 
  ArrowLeft, 
  HelpCircle, 
  MessageSquare, 
  Mail, 
  Phone, 
  ExternalLink,
  Search,
  Book,
  Video,
  FileText
} from 'lucide-react';

interface HelpScreenProps {
  onBack: () => void;
}

export function HelpScreen({ onBack }: HelpScreenProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [showContactForm, setShowContactForm] = useState(false);

  const faqItems = [
    {
      question: "How do I drop an AR memory?",
      answer: "To drop an AR memory, tap the + button on the home map, point your camera at the desired location, and tap the record button. You can add photos, videos, or audio messages."
    },
    {
      question: "Can I see memories from other users?",
      answer: "Yes! AR memories dropped by other users appear as glowing dots on your map. Tap on them to view the content they've shared at that location."
    },
    {
      question: "How do scavenger hunts work?",
      answer: "Scavenger hunts are location-based challenges with clues and rewards. Follow the purple trail on your map to discover checkpoints and unlock achievements."
    },
    {
      question: "Is my location data private?",
      answer: "Your privacy is important to us. You can control location sharing in Settings > Privacy. Your exact location is never shared - only general area information."
    },
    {
      question: "How do I add friends?",
      answer: "You can add friends by tapping on their user icon when they're nearby, through the Social tab, or by sharing your unique ARound You ID."
    },
    {
      question: "What if AR features aren't working?",
      answer: "Make sure you've granted camera and location permissions. Try restarting the app and ensure you have good lighting for AR tracking."
    },
    {
      question: "How do I delete a memory I created?",
      answer: "Long-press on your memory dot on the map and select 'Delete'. You can only delete memories you created."
    },
    {
      question: "Can I use ARound You offline?",
      answer: "Some features work offline, but AR memory discovery and social features require an internet connection. Downloaded content remains accessible."
    }
  ];

  const filteredFAQ = faqItems.filter(item => 
    item.question.toLowerCase().includes(searchQuery.toLowerCase()) ||
    item.answer.toLowerCase().includes(searchQuery.toLowerCase())
  );

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
          <h1 className="text-lg font-medium">Help & Support</h1>
          <div className="w-10" />
        </div>
      </div>

      {/* Content */}
      <div className="pt-20 px-4 pb-8">
        {!showContactForm ? (
          <>
            {/* Search */}
            <div className="mb-6">
              <div className="glass-panel rounded-2xl px-4 py-3 flex items-center space-x-3">
                <Search className="w-5 h-5 text-[#00FFF7]" />
                <Input
                  placeholder="Search help topics..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="flex-1 bg-transparent border-0 text-white placeholder:text-white/50 focus:ring-0 p-0"
                />
              </div>
            </div>

            {/* Quick Actions */}
            <div className="grid grid-cols-2 gap-4 mb-6">
              <Button
                variant="outline"
                className="h-20 rounded-2xl glass-panel border-white/20 text-white hover:neon-glow-cyan flex-col"
                onClick={() => setShowContactForm(true)}
              >
                <MessageSquare className="w-6 h-6 mb-2 text-[#00FFF7]" />
                <span className="text-sm">Contact Us</span>
              </Button>
              
              <Button
                variant="outline"
                className="h-20 rounded-2xl glass-panel border-white/20 text-white hover:neon-glow-magenta flex-col"
              >
                <Video className="w-6 h-6 mb-2 text-[#FF00A8]" />
                <span className="text-sm">Tutorials</span>
              </Button>
            </div>

            {/* FAQ Section */}
            <div className="glass-panel rounded-2xl p-4 mb-6">
              <h3 className="text-lg font-medium mb-4 flex items-center">
                <HelpCircle className="w-5 h-5 mr-2 text-[#B400FF]" />
                Frequently Asked Questions
              </h3>
              
              <Accordion type="single" collapsible className="w-full">
                {filteredFAQ.map((item, index) => (
                  <AccordionItem key={index} value={`item-${index}`}>
                    <AccordionTrigger className="text-white hover:text-[#00FFF7] text-left">
                      {item.question}
                    </AccordionTrigger>
                    <AccordionContent className="text-white/70">
                      {item.answer}
                    </AccordionContent>
                  </AccordionItem>
                ))}
              </Accordion>
            </div>

            {/* Resources */}
            <div className="glass-panel rounded-2xl p-4">
              <h3 className="text-lg font-medium mb-4 flex items-center">
                <Book className="w-5 h-5 mr-2 text-[#FFD700]" />
                Resources
              </h3>
              
              <div className="space-y-3">
                <Button 
                  variant="ghost"
                  className="w-full justify-start h-12 text-white hover:bg-white/10"
                >
                  <FileText className="w-4 h-4 mr-3 text-[#00FFF7]" />
                  User Guide
                  <ExternalLink className="w-4 h-4 ml-auto" />
                </Button>
                
                <Button 
                  variant="ghost"
                  className="w-full justify-start h-12 text-white hover:bg-white/10"
                >
                  <Video className="w-4 h-4 mr-3 text-[#FF00A8]" />
                  Video Tutorials
                  <ExternalLink className="w-4 h-4 ml-auto" />
                </Button>
                
                <Button 
                  variant="ghost"
                  className="w-full justify-start h-12 text-white hover:bg-white/10"
                >
                  <MessageSquare className="w-4 h-4 mr-3 text-[#B400FF]" />
                  Community Forum
                  <ExternalLink className="w-4 h-4 ml-auto" />
                </Button>
              </div>
            </div>
          </>
        ) : (
          /* Contact Form */
          <div className="space-y-6">
            <div className="glass-panel rounded-2xl p-4">
              <h3 className="text-lg font-medium mb-4 flex items-center">
                <MessageSquare className="w-5 h-5 mr-2 text-[#00FFF7]" />
                Contact Support
              </h3>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Subject</label>
                  <Input
                    placeholder="Brief description of your issue"
                    className="bg-white/10 border-white/20 text-white placeholder:text-white/50"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-2">Email</label>
                  <Input
                    type="email"
                    placeholder="your.email@example.com"
                    className="bg-white/10 border-white/20 text-white placeholder:text-white/50"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-2">Message</label>
                  <Textarea
                    placeholder="Describe your issue in detail..."
                    rows={4}
                    className="bg-white/10 border-white/20 text-white placeholder:text-white/50"
                  />
                </div>
                
                <div className="flex space-x-3">
                  <Button 
                    variant="outline"
                    onClick={() => setShowContactForm(false)}
                    className="flex-1 h-12 rounded-xl glass-panel border-white/20 text-white hover:bg-white/10"
                  >
                    Cancel
                  </Button>
                  <Button 
                    className="flex-1 h-12 rounded-xl cyberpunk-gradient border-0 neon-glow-cyan text-black font-medium"
                  >
                    Send Message
                  </Button>
                </div>
              </div>
            </div>

            {/* Other Contact Methods */}
            <div className="glass-panel rounded-2xl p-4">
              <h3 className="text-sm font-medium mb-3">Other Ways to Reach Us</h3>
              <div className="space-y-3">
                <div className="flex items-center space-x-3 text-sm">
                  <Mail className="w-4 h-4 text-[#00FFF7]" />
                  <span>support@aroundyou.app</span>
                </div>
                <div className="flex items-center space-x-3 text-sm">
                  <Phone className="w-4 h-4 text-[#FF00A8]" />
                  <span>+1 (555) 123-4567</span>
                </div>
                <div className="flex items-center space-x-3 text-sm">
                  <MessageSquare className="w-4 h-4 text-[#B400FF]" />
                  <span>Live chat: Mon-Fri 9AM-6PM EST</span>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}