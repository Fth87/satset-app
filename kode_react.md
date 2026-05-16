Untuk App.js :


import React, { useState, useEffect } from 'react';
import { 
  Box, Map, Camera, Scan, CheckCircle, AlertTriangle, Clock, MapPin, 
  Navigation, MessageSquare, Phone, User, Settings, Bell, BarChart2, 
  HelpCircle, WifiOff, RefreshCw, Zap, ShieldAlert, ChevronRight, 
  ChevronLeft, Filter, Truck, Package, Activity, Play, Image as ImageIcon, Check, X, LogOut, Sun, Moon,
  Eye, EyeOff, Fingerprint, LifeBuoy, Headset, Key, Mail, ArrowLeft, Users, List, Crosshair, Map as MapIcon, Compass, AlertOctagon
} from 'lucide-react';
import { MapContainer, TileLayer, Marker, Popup, Polyline } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

const customIcon = new L.Icon({
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

// --- MOCK DATA ---
const mockUser = {
  name: "Budi Santoso",
  id: "C-88291",
  zone: "Surabaya Selatan",
  vehicle: "Van - L 1234 XY"
};

const mockPackages = [
  { id: "PKG-001", recipient: "Ahmad Yani", address: "Jl. Margorejo Indah No. 12, Surabaya", status: "pending", priority: "high", eta: "10:30 AM", confidence: 98, cluster: "Cluster A" },
  { id: "PKG-002", recipient: "Siti Aminah", address: "Jl. Jemursari II/45", status: "clarification", priority: "medium", eta: "11:15 AM", confidence: 45, cluster: "Cluster A" },
  { id: "PKG-003", recipient: "Budi Jaya", address: "Rungkut Asri Timur XVIII", status: "delivered", priority: "low", eta: "09:00 AM", confidence: 100, cluster: "Cluster B" },
  { id: "PKG-004", recipient: "Diana Sari", address: "Kutisari Selatan No. 8", status: "pending", priority: "medium", eta: "13:00 PM", confidence: 92, cluster: "Cluster C" },
];

const mockAIChat = [
  { sender: "ai", text: "Halo Bpk/Ibu Siti, kami dari Smart Logistics. Alamat 'Jl. Jemursari II/45' kurang lengkap bloknya. Boleh dibantu blok berapa?", time: "08:15" },
  { sender: "customer", text: "Oh iya mas, itu Blok C no 45 ya.", time: "08:20" },
  { sender: "ai", text: "Baik, alamat telah diupdate oleh AI menjadi: Jl. Jemursari II Blok C No 45. Terima kasih!", time: "08:21" }
];

// --- MAIN COMPONENT ---
export default function App() {
  const [currentScreen, setCurrentScreen] = useState('splash');
  const [navParams, setNavParams] = useState(null);
  const [theme, setTheme] = useState('light');
  const [toast, setToast] = useState(null);
  const [userRole, setUserRole] = useState(null); // 'courier' or 'dispatcher'

  const navigate = (screen, params = null) => {
    setCurrentScreen(screen);
    setNavParams(params);
    window.scrollTo(0, 0);
  };

  const showToast = (msg, type = 'info') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  // --- SCREENS ---

  // 1. Splash & Onboarding
  const SplashScreen = () => {
    const [step, setStep] = useState(1);

    const slides = [
      { icon: <Navigation size={64} className="text-zinc-950 mb-8" strokeWidth={1.5} />, title: "Neo-Industrial Routing", desc: "Sistem routing presisi tinggi didukung oleh AI Agentic." },
      { icon: <Scan size={64} className="text-zinc-950 mb-8" strokeWidth={1.5} />, title: "Scan & Extract", desc: "Otomatisasi pembacaan resi dan ekstraksi data lokasi." },
      { icon: <RefreshCw size={64} className="text-zinc-950 mb-8" strokeWidth={1.5} />, title: "Self-Healing Logistics", desc: "Sistem cerdas memulihkan kendala alamat secara independen." }
    ];

    return (
      <div className="flex flex-col h-screen bg-white p-5 justify-between">
        <div className="flex-1 flex flex-col items-start justify-center">
          {slides[step-1]?.icon}
          <h2 className="text-[24px] font-bold text-zinc-950 mb-4 tracking-tight leading-tight">{slides[step-1]?.title || "Mulai"}</h2>
          <p className="text-[16px] text-zinc-600 leading-relaxed">{slides[step-1]?.desc}</p>
        </div>
        <div className="flex flex-col gap-6 pb-8">
          <div className="flex space-x-2">
            {[1, 2, 3].map(i => (
              <div key={i} className={`h-1 w-8 rounded-none transition-colors duration-300 ${step === i ? 'bg-zinc-950' : 'bg-zinc-200'}`} />
            ))}
          </div>
          <div className="flex space-x-4">
            {step > 1 && (
              <button onClick={() => setStep(step - 1)} className="h-14 flex-1 bg-white border border-zinc-200 text-zinc-950 font-bold rounded-2xl flex items-center justify-center tracking-widest uppercase text-[14px] active:bg-zinc-50">
                BACK
              </button>
            )}
            <button 
              onClick={() => step < 3 ? setStep(step + 1) : navigate('login')} 
              className="h-14 flex-1 bg-zinc-950 text-white font-bold rounded-2xl flex items-center justify-center tracking-widest uppercase text-[14px] active:scale-[0.98] transition-transform"
            >
              {step < 3 ? 'NEXT' : 'GET STARTED'}
            </button>
          </div>
        </div>
      </div>
    );
  };

  // 2. Login
  const LoginScreen = () => {
    const [showPassword, setShowPassword] = useState(false);
    const [errorMsg, setErrorMsg] = useState(null);

    const handleMockLogin = (role = 'courier') => {
      setErrorMsg(null);
      setUserRole(role);
      navigate(role === 'dispatcher' ? 'dispatcherDashboard' : 'dashboard');
    };

    const handleBiometricLogin = () => {
      setErrorMsg(null);
      setUserRole('courier');
      navigate('dashboard');
    };

    return (
      <div className="flex flex-col h-screen bg-white p-5 justify-center relative">
        <div className="mb-10">
          <Box size={48} className="text-zinc-950 mb-6" strokeWidth={1.5} />
          <h1 className="text-[28px] font-bold text-zinc-950 tracking-tight leading-none mb-2">Operator Login</h1>
          <p className="text-zinc-500 text-[14px]">Akses terminal pengiriman Anda.</p>
        </div>

        <div className="space-y-6">
          <div>
            <label className="block text-[10px] font-bold tracking-widest uppercase text-zinc-500 mb-1">Email Address</label>
            <input 
              type="email" 
              placeholder="operator@smartlog.com" 
              className="w-full border-b border-zinc-200 focus:border-b-2 focus:border-zinc-950 outline-none bg-transparent py-2 text-[16px] text-zinc-950 rounded-none transition-all" 
              defaultValue="budi@smartlog.com" 
            />
          </div>
          
          <div>
            <label className="block text-[10px] font-bold tracking-widest uppercase text-zinc-500 mb-1">Access Key</label>
            <div className="relative">
              <input 
                type={showPassword ? "text" : "password"} 
                placeholder="••••••••" 
                className="w-full border-b border-zinc-200 focus:border-b-2 focus:border-zinc-950 outline-none bg-transparent py-2 text-[16px] text-zinc-950 rounded-none transition-all pr-10" 
                defaultValue="password123" 
              />
              <button 
                type="button" 
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-0 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-950 transition-colors"
              >
                {showPassword ? <EyeOff size={20} strokeWidth={1.5} /> : <Eye size={20} strokeWidth={1.5} />}
              </button>
            </div>
          </div>
          
          <div className="flex justify-between items-center mt-6">
            <label className="flex items-center text-zinc-600 text-[13px] font-medium cursor-pointer">
              <input type="checkbox" className="mr-2 w-4 h-4 rounded-sm border-zinc-300 accent-zinc-950" defaultChecked /> 
              Remember Me
            </label>
            <button onClick={() => navigate('forgotPassword')} className="text-zinc-950 font-bold text-[13px] hover:underline">Forgot Password?</button>
          </div>

          <div className="flex space-x-3 pt-6">
            <button 
              onClick={() => handleMockLogin('courier')} 
              className="h-14 flex-1 bg-zinc-950 text-white font-bold rounded-2xl flex items-center justify-center tracking-widest uppercase text-[13px] shadow-sm active:scale-[0.98] transition-transform"
            >
              LOGIN COURIER
            </button>
            <button 
              onClick={() => handleMockLogin('dispatcher')} 
              className="h-14 flex-1 bg-zinc-950 text-white font-bold rounded-2xl flex items-center justify-center tracking-widest uppercase text-[13px] shadow-sm active:scale-[0.98] transition-transform"
            >
              LOGIN DISPATCH
            </button>
          </div>
        </div>

        <div className="absolute bottom-8 left-0 w-full flex justify-center space-x-10 text-zinc-500">
          <button className="flex flex-col items-center hover:text-zinc-950 transition-colors">
            <LifeBuoy size={20} className="mb-1.5" strokeWidth={1.5} />
            <span className="text-[10px] font-bold tracking-widest uppercase">Help</span>
          </button>
          <button className="flex flex-col items-center hover:text-zinc-950 transition-colors">
            <Headset size={20} className="mb-1.5" strokeWidth={1.5} />
            <span className="text-[10px] font-bold tracking-widest uppercase">Dispatcher</span>
          </button>
        </div>
      </div>
    );
  };

  // 2.1 Forgot Password
  const ForgotPasswordScreen = () => {
    const [submitted, setSubmitted] = useState(false);

    const handleReset = (e) => {
      e.preventDefault();
      setSubmitted(true);
      showToast('Reset link sent to your email', 'success');
    };

    return (
      <div className="flex flex-col h-screen bg-white p-5 justify-center relative">
        <button 
          onClick={() => navigate('login')}
          className="absolute top-10 left-5 p-2 bg-zinc-50 border border-zinc-100 rounded-full text-zinc-950"
        >
          <ArrowLeft size={24} strokeWidth={1.5} />
        </button>

        <div className="mb-10">
          <div className="w-16 h-16 bg-zinc-50 border border-zinc-200 rounded-3xl flex items-center justify-center text-zinc-950 mb-6">
            <Key size={32} strokeWidth={1.5} />
          </div>
          <h1 className="text-[28px] font-bold text-zinc-950 tracking-tight leading-none mb-3">Forgot Password</h1>
          <p className="text-zinc-500 text-[14px] leading-relaxed">
            {submitted 
              ? "Instruksi reset kata sandi telah dikirim ke email Anda. Silakan periksa kotak masuk." 
              : "Masukkan email Anda untuk menerima tautan pemulihan kata sandi."}
          </p>
        </div>

        {!submitted ? (
          <form onSubmit={handleReset} className="space-y-8">
            <div>
              <label className="block text-[10px] font-bold tracking-widest uppercase text-zinc-500 mb-1">Email Address</label>
              <div className="relative">
                <input 
                  type="email" 
                  required
                  placeholder="operator@smartlog.com" 
                  className="w-full border-b border-zinc-200 focus:border-b-2 focus:border-zinc-950 outline-none bg-transparent py-2 text-[16px] text-zinc-950 rounded-none transition-all pr-10" 
                />
                <Mail size={18} className="absolute right-0 top-1/2 -translate-y-1/2 text-zinc-300" strokeWidth={1.5} />
              </div>
            </div>

            <button 
              type="submit"
              className="h-14 w-full bg-zinc-950 text-white font-bold rounded-2xl flex items-center justify-center tracking-widest uppercase text-[13px] shadow-sm active:scale-[0.98] transition-transform"
            >
              SEND RESET LINK
            </button>
          </form>
        ) : (
          <button 
            onClick={() => navigate('login')}
            className="h-14 w-full bg-white border border-zinc-950 text-zinc-950 font-bold rounded-2xl flex items-center justify-center tracking-widest uppercase text-[13px] shadow-sm"
          >
            BACK TO LOGIN
          </button>
        )}
      </div>
    );
  };

  // 3. Dashboard
  const DashboardScreen = () => {
    const today = new Date().toLocaleDateString('en-US', { weekday: 'short', day: 'numeric', month: 'short' });

    return (
      <div className="min-h-screen bg-zinc-50 pb-24">
        {/* Header with Logs (Bell) Icon in Home */}
        <div className="bg-white border-b border-zinc-200 p-5 rounded-b-3xl shadow-sm">
          <div className="flex justify-between items-center mb-6">
            <div>
              <h2 className="text-[20px] font-bold text-zinc-950 tracking-tight leading-none">Overview</h2>
              <p className="text-[12px] font-bold tracking-widest uppercase text-zinc-500 mt-2">{today}</p>
            </div>
            {/* Logs Moved to Home Header */}
            <button onClick={() => navigate('notifications')} className="w-12 h-12 border border-zinc-200 rounded-full flex items-center justify-center bg-white text-zinc-950 hover:bg-zinc-50 transition-colors shadow-sm">
              <Bell size={20} strokeWidth={1.5} />
            </button>
          </div>
          
          <div className="grid grid-cols-4 gap-3">
            <div className="border border-zinc-200 bg-white rounded-2xl p-3 flex flex-col items-center shadow-sm">
              <p className="text-[20px] font-bold text-zinc-950">42</p>
              <p className="text-[10px] font-bold tracking-wider uppercase text-zinc-500 mt-1 flex items-center">Total</p>
            </div>
            <div className="border border-zinc-200 bg-white rounded-2xl p-3 flex flex-col items-center shadow-sm">
              <p className="text-[20px] font-bold text-zinc-950">12</p>
              <p className="text-[10px] font-bold tracking-wider uppercase text-zinc-500 mt-1 flex items-center"><Check size={12} strokeWidth={2.5} className="mr-1" />Done</p>
            </div>
            <div className="border border-zinc-200 bg-white rounded-2xl p-3 flex flex-col items-center shadow-sm">
              <p className="text-[20px] font-bold text-zinc-950">28</p>
              <p className="text-[10px] font-bold tracking-wider uppercase text-zinc-500 mt-1 flex items-center"><Clock size={12} strokeWidth={2.5} className="mr-1" />Pend</p>
            </div>
            <div className="border border-zinc-200 bg-white rounded-2xl p-3 flex flex-col items-center shadow-sm">
              <p className="text-[20px] font-bold text-zinc-950">2</p>
              <p className="text-[10px] font-bold tracking-wider uppercase text-zinc-500 mt-1 flex items-center"><X size={12} strokeWidth={2.5} className="mr-1" />Fail</p>
            </div>
          </div>
        </div>

        <div className="p-5 space-y-6">
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-white p-4 rounded-3xl border border-zinc-200 shadow-sm">
              <div className="flex justify-between items-center mb-3">
                <span className="text-[10px] font-bold tracking-widest uppercase text-zinc-500">Weather</span>
                <Sun size={18} className="text-zinc-600" />
              </div>
              <p className="text-[28px] font-bold text-zinc-950 leading-none mb-2">32°</p>
              <p className="text-[13px] text-zinc-500 leading-snug">Clear conditions expected.</p>
            </div>
            <div className="bg-white p-4 rounded-3xl border border-zinc-200 shadow-sm">
              <div className="flex justify-between items-center mb-3">
                <span className="text-[10px] font-bold tracking-widest uppercase text-zinc-500">Traffic</span>
                <AlertTriangle size={18} className="text-zinc-600" />
              </div>
              <p className="text-[20px] font-bold text-zinc-950 leading-none mb-1">Moderate</p>
              <p className="text-[13px] text-zinc-500 mt-3 leading-snug">+12m delay on route.</p>
            </div>
          </div>

          <div className="bg-white p-6 rounded-[32px] border border-zinc-200 shadow-sm">
            <h3 className="text-[32px] font-bold text-zinc-950 tracking-tight leading-none mb-6">42 Packages Total</h3>
            
            <div className="flex justify-between items-center mb-2">
              <span className="text-[13px] font-medium text-zinc-700">Route Progress</span>
              <span className="text-[13px] font-bold text-zinc-500">12 / 42</span>
            </div>
            
            <div className="w-full bg-zinc-200 h-2 rounded-full mb-3">
              <div className="bg-zinc-800 h-2 rounded-full" style={{width: '28%'}}></div>
            </div>
            
            <p className="text-[10px] font-bold tracking-widest uppercase text-zinc-500 mb-6">Est. Completion 16:30</p>
            
            <div className="space-y-3">
              <button onClick={() => navigate('routeSummary')} className="w-full h-14 bg-zinc-950 text-white rounded-2xl font-bold uppercase tracking-widest text-[14px] flex items-center justify-center transition-transform active:scale-[0.98] shadow-sm">
                <Play size={18} className="mr-2" strokeWidth={2} fill="currentColor" /> START ROUTE
              </button>
              <button onClick={() => navigate('scanner')} className="w-full h-14 bg-white border border-zinc-200 text-zinc-950 rounded-2xl font-bold uppercase tracking-widest text-[13px] flex items-center justify-center hover:bg-zinc-50 transition-transform active:scale-[0.98] shadow-sm">
                <Scan size={18} className="mr-2" strokeWidth={2} /> SCAN NEW PACKAGE
              </button>
            </div>
          </div>

          <div>
            <h3 className="text-[12px] font-bold tracking-widest uppercase text-zinc-500 mb-3 ml-1">AI Agents Subsystem</h3>
            <div className="grid grid-cols-3 gap-2">
              <div className="bg-white p-3 rounded-2xl border border-zinc-200 shadow-sm flex flex-col justify-between">
                <div className="mb-2">
                  <Scan size={20} className="text-zinc-950" />
                </div>
                <div>
                  <p className="text-[11px] font-bold text-zinc-950 uppercase tracking-tight leading-none">OCR Core</p>
                  <p className="text-[10px] text-zinc-500 mt-1">Active</p>
                </div>
              </div>
              <div className="bg-white p-3 rounded-2xl border border-zinc-200 shadow-sm flex flex-col justify-between">
                <div className="mb-2">
                  <Map size={20} className="text-zinc-950" />
                </div>
                <div>
                  <p className="text-[11px] font-bold text-zinc-950 uppercase tracking-tight leading-none">Routing</p>
                  <p className="text-[10px] text-zinc-500 mt-1">Optimizing</p>
                </div>
              </div>
              <div className="bg-white p-3 rounded-2xl border border-zinc-200 shadow-sm cursor-pointer hover:bg-zinc-50 transition-colors flex flex-col justify-between" onClick={() => navigate('clarification')}>
                <div className="mb-2">
                  <MessageSquare size={20} className="text-zinc-950" />
                </div>
                <div>
                  <p className="text-[11px] font-bold text-zinc-950 uppercase tracking-tight leading-none">Comm AI</p>
                  <p className="text-[10px] text-zinc-500 mt-1">1 Action</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  };

  // 4. Scanner
  const ScannerScreen = () => {
    const [scanned, setScanned] = useState(false);
    
    return (
      <div className="flex flex-col h-screen bg-zinc-950 relative">
        <div className="p-5 flex justify-between items-center text-white absolute top-0 w-full z-10 border-b border-zinc-800">
          <button onClick={() => navigate('dashboard')}><X size={24} /></button>
          <span className="text-[12px] font-bold uppercase tracking-widest">Data Extraction</span>
          <ImageIcon size={20} />
        </div>
        
        <div className="flex-1 flex items-center justify-center relative bg-zinc-950">
          <div className="w-72 h-72 border border-zinc-600 rounded-3xl relative overflow-hidden">
            <div className="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.05)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.05)_1px,transparent_1px)] bg-[size:20px_20px]"></div>
            <div className="absolute top-0 left-0 w-full h-[1px] bg-white animate-[scan_2s_ease-in-out_infinite]" />
            <div className="absolute top-0 left-0 w-6 h-6 border-t-4 border-l-4 border-white rounded-tl-2xl"></div>
            <div className="absolute top-0 right-0 w-6 h-6 border-t-4 border-r-4 border-white rounded-tr-2xl"></div>
            <div className="absolute bottom-0 left-0 w-6 h-6 border-b-4 border-l-4 border-white rounded-bl-2xl"></div>
            <div className="absolute bottom-0 right-0 w-6 h-6 border-b-4 border-r-4 border-white rounded-br-2xl"></div>
          </div>
        </div>

        {scanned ? (
          <div className="bg-white border-t border-zinc-200 p-6 absolute bottom-0 w-full animate-slideUp rounded-t-3xl">
             <div className="flex justify-between items-center mb-6 pb-4 border-b border-zinc-200">
                <span className="bg-white border border-zinc-200 text-zinc-950 px-3 py-1 rounded-full text-[10px] font-bold tracking-widest uppercase flex items-center shadow-sm">
                   <Check size={12} strokeWidth={2.5} className="mr-1" /> Match: 98%
                </span>
                <span className="text-[12px] font-bold text-zinc-500 uppercase tracking-widest">Valid Syntax</span>
             </div>
             <div className="space-y-4 mb-8">
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-1">Recipient</p>
                  <p className="text-[16px] font-medium text-zinc-950">Joko Anwar</p>
                </div>
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-1">Extracted Address</p>
                  <p className="text-[16px] font-medium text-zinc-950 leading-relaxed">Jl. Darmo Permai II No. 14, Pradahkalikendal, Dukuhpakis, Surabaya 60226</p>
                </div>
             </div>
             <div className="flex space-x-3">
                <button onClick={() => setScanned(false)} className="h-14 flex-1 bg-white border border-zinc-200 rounded-2xl text-zinc-950 font-bold uppercase tracking-widest text-[12px] active:bg-zinc-50 shadow-sm">Retake</button>
                <button onClick={() => { showToast('Payload injected to Manifest', 'success'); navigate('dashboard'); }} className="h-14 flex-1 bg-zinc-950 rounded-2xl text-white font-bold uppercase tracking-widest text-[12px] active:scale-[0.98] transition-transform shadow-sm">Commit Data</button>
             </div>
          </div>
        ) : (
          <div className="pb-12 pt-6 flex justify-center w-full absolute bottom-0 border-t border-zinc-800 bg-zinc-950/80 backdrop-blur-sm">
            <button onClick={() => setScanned(true)} className="w-20 h-20 bg-transparent rounded-full border-4 border-zinc-400 flex items-center justify-center active:bg-zinc-800 transition">
              <div className="w-14 h-14 bg-white rounded-full"></div>
            </button>
          </div>
        )}
      </div>
    );
  };

  // 15. Route Optimization Summary
  const RouteSummaryScreen = () => (
    <div className="min-h-screen bg-white flex flex-col">
      <Header title="Routing Protocol" backTo="dashboard" />
      <div className="flex-1 p-5 space-y-4">
        
        <div className="bg-white p-6 border border-zinc-200 rounded-3xl flex flex-col items-center text-center shadow-sm">
          <Activity className="text-zinc-950 mb-4" size={32} strokeWidth={1.5} />
          <h2 className="text-[16px] font-bold text-zinc-950 uppercase tracking-widest mb-2 flex items-center">
            <Activity size={18} strokeWidth={2.5} className="mr-2" />Algorithm Finalized
          </h2>
          <p className="text-[12px] text-zinc-500 font-bold tracking-widest uppercase mt-2">Observe → Think → Decide → Act</p>
        </div>

        <div className="bg-white border border-zinc-200 rounded-3xl overflow-hidden shadow-sm">
          <div className="p-5 border-b border-zinc-200 flex justify-between items-center">
             <span className="text-[12px] font-bold uppercase tracking-widest text-zinc-500">Waypoints</span>
             <span className="text-[16px] font-bold text-zinc-950">28 Nodes</span>
          </div>
          <div className="p-5 border-b border-zinc-200 flex justify-between items-center">
             <span className="text-[12px] font-bold uppercase tracking-widest text-zinc-500">Est. Duration</span>
             <span className="text-[16px] font-bold text-zinc-950">4h 15m</span>
          </div>
          <div className="p-5 flex justify-between items-center">
             <span className="text-[12px] font-bold uppercase tracking-widest text-zinc-500">Risk Factor</span>
             <span className="text-[10px] font-bold uppercase tracking-widest text-zinc-950 border border-zinc-200 bg-zinc-50 px-3 py-1 rounded-full flex items-center">
               <AlertTriangle size={12} strokeWidth={2.5} className="mr-1.5" />Medium
             </span>
          </div>
        </div>

        <div className="pt-6 space-y-3">
          <button onClick={() => navigate('manifest')} className="h-14 w-full bg-zinc-950 text-white font-bold rounded-2xl flex items-center justify-center uppercase tracking-widest text-[14px] shadow-sm active:scale-[0.98] transition-transform">
            Accept & Initialize
          </button>
          <button className="h-14 w-full bg-white border border-zinc-200 text-zinc-950 font-bold rounded-2xl flex items-center justify-center uppercase tracking-widest text-[14px] shadow-sm active:bg-zinc-50">
            Force Recalculate
          </button>
        </div>
      </div>
    </div>
  );

  // 5. Manifest
  const ManifestScreen = () => (
    <div className="min-h-screen bg-white pb-24">
      <Header title="Active Manifest" backTo="dashboard" rightIcon={<Filter size={20} />} />
      <div className="px-5 py-3 flex space-x-3 overflow-x-auto bg-white border-b border-zinc-200 no-scrollbar">
        <span className="px-4 py-2 bg-zinc-950 text-white rounded-full border border-zinc-950 text-[10px] font-bold uppercase tracking-widest whitespace-nowrap">Global (42)</span>
        <span className="px-4 py-2 bg-white text-zinc-600 rounded-full border border-zinc-200 text-[10px] font-bold uppercase tracking-widest whitespace-nowrap hover:bg-zinc-50 shadow-sm">Pending (28)</span>
        <span className="px-4 py-2 bg-white text-zinc-600 rounded-full border border-zinc-200 text-[10px] font-bold uppercase tracking-widest whitespace-nowrap hover:bg-zinc-50 shadow-sm">Anomaly (1)</span>
      </div>

      <div className="p-5 space-y-4">
        {mockPackages.map((pkg, idx) => (
          <div key={idx} onClick={() => navigate('deliveryDetail', pkg)} className="bg-white p-5 border border-zinc-200 rounded-3xl cursor-pointer hover:border-zinc-400 transition-colors shadow-sm">
            <div className="flex justify-between items-start mb-3">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-1">{pkg.id}</p>
                <h4 className="text-[16px] font-bold text-zinc-950 tracking-tight">{pkg.recipient}</h4>
              </div>
              {pkg.status === 'pending' && <span className="bg-white border border-zinc-200 text-zinc-950 text-[10px] px-3 py-1 rounded-full font-bold uppercase tracking-widest">{pkg.eta}</span>}
              {pkg.status === 'delivered' && <span className="bg-white border border-zinc-200 text-zinc-950 text-[10px] px-3 py-1 rounded-full font-bold uppercase tracking-widest flex items-center"><Check size={12} strokeWidth={2.5} className="mr-1" />Done</span>}
              {pkg.status === 'clarification' && <span className="bg-white border border-zinc-200 text-zinc-950 text-[10px] px-3 py-1 rounded-full font-bold uppercase tracking-widest flex items-center"><AlertTriangle size={12} strokeWidth={2.5} className="mr-1" />Comm AI</span>}
            </div>
            <p className="text-[14px] text-zinc-600 mb-5 truncate">{pkg.address}</p>
            {pkg.status === 'pending' && (
              <button onClick={(e) => { e.stopPropagation(); navigate('mapNav'); }} className="h-12 w-full border border-zinc-200 bg-white text-zinc-950 rounded-2xl text-[12px] font-bold uppercase tracking-widest flex items-center justify-center hover:bg-zinc-50 transition-colors shadow-sm">
                <Navigation size={14} className="mr-2"/> Navigate Vector
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );

  // 14. AI Clarification Queue
  const ClarificationScreen = () => (
    <div className="min-h-screen bg-zinc-50">
      <Header title="Anomaly Handling" backTo="dashboard" />
      <div className="p-5 space-y-5">
        <div className="bg-white border border-zinc-200 p-5 rounded-3xl shadow-sm">
          <div className="flex items-center text-zinc-950 mb-3 font-bold uppercase tracking-widest text-[12px]">
            <AlertTriangle size={16} className="mr-2" strokeWidth={2.5} /> Autonomous Protocol
          </div>
          <p className="text-[14px] text-zinc-600 leading-relaxed">1 paket sedang diklarifikasi oleh Agent via protokol eksternal (WhatsApp).</p>
        </div>

        {mockPackages.filter(p => p.status === 'clarification').map((pkg, idx) => (
          <div key={idx} className="bg-white p-5 border border-zinc-200 rounded-3xl shadow-sm">
            <div className="mb-5">
              <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-1">{pkg.id}</p>
              <h4 className="text-[16px] font-bold text-zinc-950">{pkg.recipient}</h4>
              <p className="text-[14px] text-zinc-400 mt-1 line-through">{pkg.address}</p>
            </div>
            <div className="bg-zinc-50 border border-zinc-200 p-4 rounded-2xl text-[13px] mb-6 text-zinc-700 leading-relaxed">
              <span className="font-bold text-zinc-950 uppercase text-[10px] tracking-widest block mb-2">Status Log:</span> Menunggu respons data spesifik (nomor blok) dari Node Pelanggan.
            </div>
            <div className="flex space-x-3">
              <button className="h-14 flex-1 bg-white border border-zinc-200 text-zinc-950 rounded-2xl text-[12px] font-bold uppercase tracking-widest hover:bg-zinc-50 shadow-sm">Manual Override</button>
              <button className="h-14 flex-1 bg-zinc-950 text-white rounded-2xl text-[12px] font-bold uppercase tracking-widest hover:bg-zinc-800 shadow-sm">Inject Data</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  // 5. Incident Report
  const IncidentReportScreen = () => (
    <div className="min-h-screen bg-zinc-50">
      <Header title="Incident Report" backTo="dashboard" rightIcon={<List size={20} />} onRightClick={() => navigate('incidentDetail')} />
      <div className="p-5 space-y-5">
        <div className="bg-white border border-zinc-200 rounded-3xl p-5 shadow-sm">
          <h2 className="text-[16px] font-bold text-zinc-950 mb-2">Laporkan Insiden</h2>
          <p className="text-[14px] text-zinc-600 leading-relaxed">Gunakan form ini untuk mencatat gangguan, kecelakaan, atau kejadian lain selama pengiriman.</p>
        </div>

        <div className="bg-white border border-zinc-200 rounded-3xl p-5 shadow-sm space-y-4">
          <div>
            <label className="block text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-2">Jenis Insiden</label>
            <select className="w-full border border-zinc-200 rounded-2xl p-3 text-[14px] text-zinc-950 outline-none focus:border-zinc-950 transition">
              <option>Delay</option>
              <option>Vehicle Issue</option>
              <option>Package Damage</option>
              <option>Route Blocked</option>
              <option>Other</option>
            </select>
          </div>
          <div>
            <label className="block text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-2">Detail</label>
            <textarea rows="5" className="w-full border border-zinc-200 rounded-3xl p-3 text-[14px] text-zinc-950 outline-none focus:border-zinc-950 transition" placeholder="Jelaskan apa yang terjadi..."></textarea>
          </div>
          <button onClick={() => { showToast('Incident report submitted', 'success'); navigate('dashboard'); }} className="h-14 w-full bg-zinc-950 text-white rounded-2xl font-bold uppercase tracking-widest text-[13px] shadow-sm hover:bg-zinc-800 active:scale-[0.98] transition-transform">
            SUBMIT REPORT
          </button>
        </div>
      </div>
    </div>
  );

  // 6. Map & Live Navigation
  const MapNavScreen = () => {
    const routeNodes = [
      { id: "start", pos: [-7.250445, 112.768845], label: "Current Location (Start)" },
      { id: "stop1", pos: [-7.255000, 112.770000], label: "Stop 1: Jl. Margorejo Indah" },
      { id: "stop2", pos: [-7.260445, 112.778845], label: "Stop 2: Jl. Jemursari II/45" },
      { id: "stop3", pos: [-7.265000, 112.785000], label: "Stop 3: Rungkut Asri Timur XVIII" }
    ];
    
    return (
    <div className="flex flex-col h-screen bg-white relative">
      <div className="absolute inset-0 bg-zinc-50 z-0">
         <MapContainer center={routeNodes[0].pos} zoom={14} style={{ height: '100%', width: '100%' }} zoomControl={false}>
            <TileLayer
              url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            />
            {routeNodes.map((node, index) => (
              <Marker key={node.id} position={node.pos} icon={customIcon}>
                <Popup>{node.label}</Popup>
              </Marker>
            ))}
            <Polyline positions={routeNodes.map(n => n.pos)} color="#09090b" weight={4} dashArray="8, 8" />
         </MapContainer>
      </div>
      
      <div className="absolute inset-0 z-10 flex flex-col justify-between pointer-events-none">
        <div className="p-5 pointer-events-auto mt-4">
          <div className="bg-zinc-950 text-white p-5 rounded-3xl flex items-center shadow-lg">
             <div className="mr-5"><Navigation size={32} className="transform rotate-45" strokeWidth={1.5} /></div>
             <div>
                <p className="text-[28px] font-bold tracking-tight leading-none mb-1">250m</p>
                <p className="text-[14px] text-zinc-400 font-medium tracking-wide">Turn Left - Jl. Margorejo Indah</p>
             </div>
          </div>
        </div>

        <div className="flex items-center justify-center flex-1">
           <div className="w-14 h-14 bg-white border-4 border-zinc-950 rounded-full flex items-center justify-center shadow-lg">
             <Navigation size={24} className="text-zinc-950 transform -rotate-45" />
           </div>
        </div>

        <div className="bg-white border-t border-zinc-200 p-6 pb-24 rounded-t-[32px] pointer-events-auto shadow-[0_-10px_40px_rgba(0,0,0,0.05)]">
          <div className="flex justify-between items-end mb-6">
            <div>
              <p className="text-[32px] font-bold text-zinc-950 tracking-tight leading-none mb-1">10:30 <span className="text-[12px] text-zinc-500 font-bold uppercase tracking-widest ml-1">ETA</span></p>
              <p className="text-zinc-600 text-[14px] font-medium">1.2 km • 5 min remaining</p>
            </div>
            <button onClick={() => navigate('incidentReport')} className="w-14 h-14 border border-zinc-200 bg-white text-zinc-950 rounded-2xl flex items-center justify-center hover:bg-zinc-50 transition-colors shadow-sm">
              <AlertTriangle size={20} />
            </button>
          </div>
          <div className="flex space-x-3">
            <button onClick={() => navigate('manifest')} className="h-14 w-16 bg-white border border-zinc-200 text-zinc-950 rounded-2xl font-bold uppercase tracking-widest flex justify-center items-center hover:bg-zinc-50 shadow-sm">
              <X size={20} />
            </button>
            <button onClick={() => navigate('deliveryDetail', mockPackages[0])} className="h-14 flex-1 bg-zinc-950 text-white rounded-2xl font-bold uppercase tracking-widest text-[14px] shadow-sm active:scale-[0.98] transition-transform">
              CONFIRM ARRIVAL
            </button>
          </div>
        </div>
      </div>
    </div>
  );
  };

  // 7. Delivery Detail & Chat Log
  const DeliveryDetailScreen = () => {
    const pkg = navParams || mockPackages[0];
    return (
      <div className="min-h-screen bg-zinc-50 pb-24">
        <Header title="Payload Data" backTo="manifest" />
        <div className="p-5 space-y-5">
          <div className="bg-white p-6 border border-zinc-200 rounded-3xl shadow-sm">
            <div className="flex justify-between items-center mb-5 pb-4 border-b border-zinc-100">
              <span className="font-bold text-[14px] text-zinc-950 tracking-wide">{pkg.id}</span>
              <span className="bg-white border border-zinc-200 text-zinc-950 text-[10px] px-3 py-1.5 rounded-full font-bold uppercase tracking-widest">Class: {pkg.priority}</span>
            </div>
            
            <h2 className="text-[20px] font-bold text-zinc-950 mb-2 tracking-tight">{pkg.recipient}</h2>
            <p className="text-[14px] text-zinc-600 mb-6 flex items-start leading-relaxed"><MapPin size={16} className="mr-3 text-zinc-950 mt-1 flex-shrink-0" /> {pkg.address}</p>
            
            <div className="flex space-x-3 mt-2">
              <button className="flex-1 h-14 bg-white border border-zinc-200 text-zinc-950 rounded-2xl font-bold uppercase tracking-widest text-[12px] flex justify-center items-center hover:bg-zinc-50 transition-colors shadow-sm">
                <Phone size={18} className="mr-2"/> Call
              </button>
              <button className="flex-1 h-14 bg-white border border-zinc-200 text-zinc-950 rounded-2xl font-bold uppercase tracking-widest text-[12px] flex justify-center items-center hover:bg-zinc-50 transition-colors shadow-sm">
                <MessageSquare size={18} className="mr-2"/> Comm
              </button>
            </div>
          </div>

          <div className="bg-white p-6 border border-zinc-200 rounded-3xl shadow-sm">
            <h3 className="text-[12px] font-bold uppercase tracking-widest text-zinc-500 mb-5 border-b border-zinc-100 pb-4 flex items-center">
              <Zap size={14} className="text-zinc-950 mr-2"/> Communication Log
            </h3>
            <div className="space-y-5">
              {mockAIChat.map((msg, i) => (
                <div key={i} className={`flex flex-col ${msg.sender === 'ai' ? 'items-start' : 'items-end'}`}>
                  <div className={`p-4 rounded-2xl text-[13px] leading-relaxed max-w-[85%] border ${msg.sender === 'ai' ? 'bg-zinc-50 border-zinc-200 text-zinc-800 rounded-tl-sm' : 'bg-zinc-950 border-zinc-950 text-white rounded-tr-sm'}`}>
                    {msg.text}
                  </div>
                  <span className="text-[10px] font-bold uppercase tracking-widest text-zinc-400 mt-2">{msg.time}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="fixed bottom-0 w-full max-w-md bg-white p-5 border-t border-zinc-200">
          <button onClick={() => navigate('pod')} className="h-14 w-full bg-zinc-950 text-white rounded-2xl font-bold uppercase tracking-widest text-[14px] shadow-sm active:scale-[0.98]">
            Execute Handover
          </button>
        </div>
      </div>
    );
  };

  // 8. Proof of Delivery (PoD)
  const PoDScreen = () => (
    <div className="min-h-screen bg-zinc-50 flex flex-col">
      <Header title="Handover Protocol" backTo="deliveryDetail" />
      <div className="flex-1 p-5 space-y-6">
        <div>
          <label className="block text-[12px] font-bold tracking-widest uppercase text-zinc-500 mb-2">Final State</label>
          <div className="relative">
             <select className="w-full bg-white border border-zinc-200 rounded-2xl px-4 py-4 text-[14px] text-zinc-950 appearance-none focus:outline-none focus:border-zinc-950 shadow-sm font-medium">
               <option>Success - Direct Handover</option>
               <option>Success - Security/Reception</option>
               <option>Abort - Location Empty</option>
               <option>Abort - Package Rejected</option>
             </select>
             <ChevronRight className="absolute right-4 top-4 transform rotate-90 text-zinc-400 pointer-events-none" size={20} />
          </div>
        </div>

        <div>
          <label className="block text-[12px] font-bold tracking-widest uppercase text-zinc-500 mb-2 mt-4">Visual Evidence</label>
          <div className="h-48 bg-white border border-zinc-200 border-dashed rounded-3xl flex flex-col items-center justify-center text-zinc-500 hover:bg-zinc-50 transition-colors cursor-pointer shadow-sm">
            <Camera size={36} className="mb-3 text-zinc-950" strokeWidth={1.5} />
            <span className="text-[12px] font-bold tracking-widest uppercase text-zinc-950">Capture Media</span>
          </div>
        </div>

        <div>
          <label className="block text-[12px] font-bold tracking-widest uppercase text-zinc-500 mb-2 mt-4">Signature Vector</label>
          <div className="h-32 bg-white border border-zinc-200 rounded-3xl flex items-center justify-center text-zinc-300 shadow-sm">
            <span className="text-[12px] uppercase tracking-widest font-bold">Draw Input</span>
          </div>
        </div>
      </div>

      <div className="p-5 bg-white border-t border-zinc-200">
         <button onClick={() => { showToast('Transaction Committed.', 'success'); navigate('dashboard'); }} className="h-14 w-full bg-zinc-950 text-white rounded-2xl font-bold uppercase tracking-widest text-[14px] shadow-sm active:scale-[0.98]">
            Finalize Entry
          </button>
      </div>
    </div>
  );

  // 9. Metrics
  const HistoryScreen = () => (
    <div className="min-h-screen bg-zinc-50 pb-24">
      <Header title="Telemetry & Metrics" />
      <div className="p-5 space-y-4">
        <div className="bg-white p-6 border border-zinc-200 rounded-3xl flex flex-col items-center shadow-sm">
          <h3 className="text-[12px] font-bold uppercase tracking-widest text-zinc-500 mb-2">Punctuality Index</h3>
          <p className="text-[48px] font-bold text-zinc-950 tracking-tighter mb-5">94%</p>
          <div className="w-full bg-zinc-100 h-2 rounded-full overflow-hidden">
            <div className="bg-zinc-950 h-2 rounded-full" style={{width: '94%'}}></div>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
           <div className="bg-white p-5 border border-zinc-200 rounded-3xl flex flex-col items-start shadow-sm">
             <Clock className="text-zinc-950 mb-4" size={24} strokeWidth={1.5} />
             <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-1">Time / Node</p>
             <p className="text-[20px] font-bold text-zinc-950">4.2 min</p>
           </div>
           <div className="bg-white p-5 border border-zinc-200 rounded-3xl flex flex-col items-start shadow-sm">
             <Map className="text-zinc-950 mb-4" size={24} strokeWidth={1.5} />
             <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-1">Vector Length</p>
             <p className="text-[20px] font-bold text-zinc-950">42 km</p>
           </div>
        </div>

        <div className="bg-white border border-zinc-200 p-6 rounded-3xl mt-2 shadow-sm">
          <div className="flex items-center text-zinc-950 mb-4 font-bold text-[12px] uppercase tracking-widest border-b border-zinc-100 pb-3">
            <Zap size={16} strokeWidth={2.5} className="mr-2"/> AI Insight Engine
          </div>
          <p className="text-[14px] text-zinc-600 leading-relaxed">Topologi rute hari ini 12% lebih efisien secara spasial dibanding data historis minggu sebelumnya.</p>
        </div>
      </div>
    </div>
  );

  // 10. Logs (Notifications)
  const NotificationsScreen = () => (
    <div className="min-h-screen bg-zinc-50 pb-24">
      <Header title="System Logs" backTo="dashboard" />
      <div className="p-5 space-y-4">
        <div className="bg-white p-6 border border-zinc-200 rounded-3xl shadow-sm">
          <div className="flex justify-between items-start mb-3 border-b border-zinc-100 pb-3">
            <h4 className="text-[14px] font-bold text-zinc-950 tracking-tight flex items-center">
              <AlertTriangle size={16} strokeWidth={2.5} className="mr-2" />Topology Override
            </h4>
            <span className="text-[10px] font-bold uppercase tracking-widest text-zinc-400">10m ago</span>
          </div>
          <p className="text-[13px] text-zinc-600 leading-relaxed">Routing diubah akibat deteksi anomali (banjir) di Sektor Kenjeran.</p>
        </div>
        <div className="bg-white p-6 border border-zinc-200 rounded-3xl shadow-sm">
          <div className="flex justify-between items-start mb-3 border-b border-zinc-100 pb-3">
            <h4 className="text-[14px] font-bold text-zinc-950 tracking-tight flex items-center">
              <CheckCircle size={16} strokeWidth={2.5} className="mr-2" />AI Resolution Success
            </h4>
            <span className="text-[10px] font-bold uppercase tracking-widest text-zinc-400">1h ago</span>
          </div>
          <p className="text-[13px] text-zinc-600 leading-relaxed">Data string alamat PKG-002 berhasil dipulihkan. Node diperbarui.</p>
        </div>
        <div className="bg-white p-6 border border-zinc-200 rounded-3xl opacity-70 shadow-sm">
          <div className="flex justify-between items-start mb-3 border-b border-zinc-100 pb-3">
            <h4 className="text-[14px] font-bold text-zinc-950 tracking-tight flex items-center">
              <User size={16} strokeWidth={2.5} className="mr-2" />Session Initiated
            </h4>
            <span className="text-[10px] font-bold uppercase tracking-widest text-zinc-400">08:00 AM</span>
          </div>
          <p className="text-[13px] text-zinc-600 leading-relaxed">Otentikasi berhasil. Selamat bertugas.</p>
        </div>
      </div>
    </div>
  );

  // 11. Profile & Settings (Moved to footer nav)
  const ProfileScreen = () => (
    <div className="min-h-screen bg-zinc-50 pb-24">
      <Header title="Operator & Settings" />
      <div className="p-5 space-y-5">
        <div className="bg-white border border-zinc-200 rounded-[32px] p-8 flex flex-col items-center text-center shadow-sm relative overflow-hidden">
          <div className="w-24 h-24 bg-zinc-50 border border-zinc-200 rounded-full flex items-center justify-center text-zinc-950 mb-5 shadow-sm">
            <User size={40} strokeWidth={1.5} />
          </div>
          <h2 className="text-[24px] font-bold text-zinc-950 tracking-tight mb-2">{mockUser.name}</h2>
          <p className="text-[11px] font-bold uppercase tracking-widest text-zinc-600 bg-zinc-100 px-4 py-1.5 rounded-full inline-block">ID: {mockUser.id}</p>
        </div>

        <div className="bg-white border border-zinc-200 rounded-3xl p-2 shadow-sm">
          <div className="p-4 border-b border-zinc-100 flex items-center text-[14px] text-zinc-950 font-medium">
            <div className="w-10 h-10 bg-zinc-50 rounded-full flex items-center justify-center mr-4 border border-zinc-100"><Truck className="text-zinc-950" size={18}/></div>
            {mockUser.vehicle}
          </div>
          <div className="p-4 border-b border-zinc-100 flex items-center text-[14px] text-zinc-950 font-medium">
            <div className="w-10 h-10 bg-zinc-50 rounded-full flex items-center justify-center mr-4 border border-zinc-100"><MapPin className="text-zinc-950" size={18}/></div>
            {mockUser.zone}
          </div>
          <div className="p-4 flex items-center text-[14px] text-zinc-950 font-medium">
            <div className="w-10 h-10 bg-zinc-50 rounded-full flex items-center justify-center mr-4 border border-zinc-100"><Phone className="text-zinc-950" size={18}/></div>
            +62 812 3456 7890
          </div>
        </div>

        <div className="space-y-3">
          <button onClick={() => navigate('syncManager')} className="w-full bg-white p-5 border border-zinc-200 rounded-2xl flex items-center justify-between text-zinc-950 hover:bg-zinc-50 shadow-sm transition-colors">
            <div className="flex items-center text-[14px] font-bold tracking-wide"><RefreshCw className="mr-4 text-zinc-950" size={18}/> Storage & Sync</div>
            <ChevronRight size={18} className="text-zinc-400" />
          </button>
          <button onClick={() => navigate('settings')} className="w-full bg-white p-5 border border-zinc-200 rounded-2xl flex items-center justify-between text-zinc-950 hover:bg-zinc-50 shadow-sm transition-colors">
            <div className="flex items-center text-[14px] font-bold tracking-wide"><Settings className="mr-4 text-zinc-950" size={18}/> System Preferences</div>
            <ChevronRight size={18} className="text-zinc-400" />
          </button>
          <button onClick={() => navigate('help')} className="w-full bg-white p-5 border border-zinc-200 rounded-2xl flex items-center justify-between text-zinc-950 hover:bg-zinc-50 shadow-sm transition-colors">
            <div className="flex items-center text-[14px] font-bold tracking-wide"><HelpCircle className="mr-4 text-zinc-950" size={18}/> Protocols & SOS</div>
            <ChevronRight size={18} className="text-zinc-400" />
          </button>
          <button onClick={() => navigate('login')} className="h-16 w-full bg-white border border-zinc-200 rounded-2xl flex items-center justify-center text-zinc-950 font-bold uppercase tracking-widest text-[13px] mt-6 hover:bg-zinc-50 shadow-sm transition-colors active:scale-[0.98]">
            <LogOut className="mr-3" size={18}/> Terminate Session
          </button>
        </div>
      </div>
    </div>
  );

  // 12. Help Center & SOS
  const HelpScreen = () => (
    <div className="min-h-screen bg-zinc-50 flex flex-col">
      <Header title="Emergency Protocols" backTo="profile" />
      <div className="flex-1 p-5 flex flex-col items-center">
        <div className="flex-1 w-full flex flex-col justify-center items-center py-10">
          <button onClick={() => { showToast('CRITICAL: SOS signal broadcasted.', 'error'); navigate('dashboard'); }} className="w-48 h-48 bg-zinc-950 rounded-full mx-auto flex flex-col items-center justify-center text-white active:bg-zinc-800 transition shadow-[0_10px_40px_rgba(0,0,0,0.2)]">
            <ShieldAlert size={56} className="mb-3 text-red-500" strokeWidth={1.5} />
            <span className="font-bold text-[28px] tracking-widest text-red-500">SOS</span>
          </button>
          <p className="text-zinc-500 text-[13px] mt-8 text-center leading-relaxed max-w-xs">Tombol darurat akan membekukan aktivitas dan memindahkan vektor pengiriman ke unit cadangan terdekat.</p>
        </div>
        <div className="w-full bg-white border border-zinc-200 rounded-3xl text-left shadow-sm overflow-hidden">
          <div className="p-5 border-b border-zinc-100 text-[10px] font-bold uppercase tracking-widest text-zinc-500 bg-zinc-50/50">SOP Reference</div>
          <div className="p-5 border-b border-zinc-100 text-zinc-950 font-medium text-[14px] hover:bg-zinc-50 cursor-pointer">Prosedur Benda Pecah Belah</div>
          <div className="p-5 border-b border-zinc-100 text-zinc-950 font-medium text-[14px] hover:bg-zinc-50 cursor-pointer">Penolakan Transaksi COD</div>
          <div className="p-5 text-zinc-950 font-bold text-[14px] uppercase tracking-widest flex items-center justify-center bg-zinc-50 hover:bg-zinc-100 cursor-pointer transition-colors">Live Comm Channel</div>
        </div>
      </div>
    </div>
  );

  // 13. Settings Detail
  const SettingsScreen = () => (
    <div className="min-h-screen bg-zinc-50">
      <Header title="System Prefs" backTo="profile" />
      <div className="p-5 space-y-6">
        <div>
          <h4 className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-3 ml-2">Display & Audio</h4>
          <div className="bg-white border border-zinc-200 rounded-3xl shadow-sm">
            <div className="p-5 border-b border-zinc-100 flex justify-between items-center text-[14px] font-medium text-zinc-950">
              <span>Color Mode</span>
              <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')} className="text-zinc-950 border border-zinc-200 p-2 rounded-full hover:bg-zinc-50 transition-colors">
                {theme === 'light' ? <Moon size={16} /> : <Sun size={16} />}
              </button>
            </div>
            <div className="p-5 flex justify-between items-center text-[14px] font-medium text-zinc-950">
              <span>Nav Audio Output</span>
              <span className="text-zinc-500 text-[12px] font-bold tracking-widest uppercase bg-zinc-50 px-3 py-1 rounded-full border border-zinc-200">ID_LANG</span>
            </div>
          </div>
        </div>

        <div>
          <h4 className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-3 mt-4 ml-2">Local Data Management</h4>
          <div className="bg-white border border-zinc-200 rounded-3xl shadow-sm">
            <div className="p-5 border-b border-zinc-100 flex justify-between items-center text-[14px] font-medium text-zinc-950">
              <span>Offline Map Sector</span>
              <span className="text-[10px] font-bold tracking-widest uppercase bg-white border border-zinc-200 text-zinc-950 px-3 py-1.5 rounded-full shadow-sm">Surabaya (120MB)</span>
            </div>
            <div className="p-5 flex justify-between items-center text-[14px] font-bold text-zinc-950 uppercase tracking-widest cursor-pointer hover:bg-zinc-50 transition-colors rounded-b-3xl">
              <span className="flex items-center"><AlertTriangle size={16} strokeWidth={2.5} className="mr-2" />Purge Cache</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  // 17. Sync Manager
  const SyncManagerScreen = () => (
    <div className="min-h-screen bg-zinc-50">
      <Header title="Sync Subsystem" backTo="profile" />
      <div className="p-5 text-center flex flex-col items-center">
        <div className="mt-8 mb-8 bg-white border border-zinc-200 p-8 rounded-[32px] w-full shadow-sm">
          <WifiOff size={48} className="text-zinc-950 mx-auto mb-5" strokeWidth={1.5} />
          <h2 className="text-[20px] font-bold text-zinc-950 tracking-tight mb-3">3 Payloads Pending</h2>
          <p className="text-zinc-500 text-[14px] leading-relaxed">Jaringan tidak stabil. Data operasional tersimpan lokal dan akan dikirim otomatis saat koneksi optimal.</p>
        </div>
        
        <div className="space-y-3 w-full mb-10">
          {[1,2,3].map(i => (
             <div key={i} className="bg-white p-5 flex justify-between items-center rounded-2xl border border-zinc-200 text-left shadow-sm">
                <div>
                  <p className="font-bold text-[14px] text-zinc-950 tracking-tight mb-1">PoD Payload: PKG-00{i+2}</p>
                  <p className="text-[12px] font-medium text-zinc-500 uppercase tracking-widest text-[10px]">Status: Queued</p>
                </div>
                <Clock size={18} className="text-zinc-950" />
             </div>
          ))}
        </div>

        <button className="h-14 w-full bg-zinc-950 text-white rounded-2xl font-bold uppercase tracking-widest text-[14px] flex justify-center items-center shadow-sm active:scale-[0.98] transition-transform">
          <RefreshCw size={16} className="mr-2" /> Force Synchronization
        </button>
      </div>
    </div>
  );


  // --- DISPATCHER SCREENS ---

  const DispatcherDashboardScreen = () => {
    return (
      <div className="min-h-screen bg-zinc-50 pb-24">
        <div className="bg-white border-b border-zinc-200 p-5 rounded-b-3xl shadow-sm">
          <div className="flex justify-between items-center mb-6">
            <div>
              <h2 className="text-[20px] font-bold text-zinc-950 tracking-tight leading-none">Dispatcher Dashboard</h2>
              <p className="text-[12px] font-bold tracking-widest uppercase text-zinc-500 mt-2">Fleet Overview</p>
            </div>
            <button onClick={() => navigate('notifications')} className="w-12 h-12 border border-zinc-200 rounded-full flex items-center justify-center bg-white text-zinc-950 hover:bg-zinc-50 transition-colors shadow-sm">
              <Bell size={20} strokeWidth={1.5} />
            </button>
          </div>
          
          <div className="grid grid-cols-2 gap-3">
            <div className="border border-zinc-200 bg-white rounded-2xl p-4 shadow-sm">
              <p className="text-[10px] font-bold tracking-wider uppercase text-zinc-500 mb-1">Active Couriers</p>
              <p className="text-[28px] font-bold text-zinc-950">12</p>
            </div>
            <div className="border border-zinc-200 bg-white rounded-2xl p-4 shadow-sm">
              <p className="text-[10px] font-bold tracking-wider uppercase text-zinc-500 mb-1">Total Packages</p>
              <p className="text-[28px] font-bold text-zinc-950">245</p>
            </div>
          </div>
        </div>

        <div className="p-5 space-y-4">
          <div className="grid grid-cols-3 gap-3 mb-2">
            <div className="border border-zinc-200 bg-white rounded-2xl p-3 flex flex-col items-center shadow-sm">
              <p className="text-[20px] font-bold text-zinc-950">120</p>
              <p className="text-[10px] font-bold tracking-wider uppercase text-zinc-500 mt-1 flex items-center"><Check size={12} strokeWidth={2.5} className="mr-1" />Delivered</p>
            </div>
            <div className="border border-zinc-200 bg-white rounded-2xl p-3 flex flex-col items-center shadow-sm">
              <p className="text-[20px] font-bold text-zinc-950">118</p>
              <p className="text-[10px] font-bold tracking-wider uppercase text-zinc-500 mt-1 flex items-center"><Clock size={12} strokeWidth={2.5} className="mr-1" />Pending</p>
            </div>
            <div className="border border-zinc-200 bg-white rounded-2xl p-3 flex flex-col items-center shadow-sm">
              <p className="text-[20px] font-bold text-red-500">7</p>
              <p className="text-[10px] font-bold tracking-wider uppercase text-zinc-500 mt-1 flex items-center"><X size={12} strokeWidth={2.5} className="mr-1" />Failed</p>
            </div>
          </div>

          <div className="bg-red-50 border border-red-200 p-4 rounded-3xl flex items-start shadow-sm mb-4">
             <AlertTriangle size={24} className="text-red-500 mr-3 shrink-0" strokeWidth={1.5} />
             <div>
                <h4 className="text-[14px] font-bold text-zinc-950 tracking-tight">High Traffic Warning</h4>
                <p className="text-[12px] text-zinc-600 mt-1">Sector B is experiencing heavy delays. Re-routing recommended.</p>
             </div>
          </div>

          <div className="space-y-3">
             <button onClick={() => navigate('dispatcherLiveMap')} className="w-full h-14 bg-zinc-950 text-white rounded-2xl font-bold uppercase tracking-widest text-[13px] flex items-center justify-center shadow-sm active:scale-[0.98] transition-transform">
               <MapIcon size={18} className="mr-2" strokeWidth={2} /> OPEN LIVE FLEET MAP
             </button>
             <button onClick={() => navigate('dispatcherAssignments')} className="w-full h-14 bg-white border border-zinc-200 text-zinc-950 rounded-2xl font-bold uppercase tracking-widest text-[13px] flex items-center justify-center hover:bg-zinc-50 shadow-sm active:scale-[0.98] transition-transform">
               <Users size={18} className="mr-2" strokeWidth={2} /> MANAGE ASSIGNMENTS
             </button>
          </div>
        </div>
      </div>
    );
  };

  const DispatcherLiveMapScreen = () => {
    return (
      <div className="h-screen bg-zinc-50 relative flex flex-col">
        <Header title="Live Fleet Map" backTo="dispatcherDashboard" />
        <div className="flex-1 relative z-0">
          <MapContainer center={[-7.250445, 112.768845]} zoom={13} style={{ height: '100%', width: '100%' }} zoomControl={false}>
            <TileLayer
              url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
            />
            <Marker position={[-7.250445, 112.768845]} icon={customIcon}>
              <Popup>Courier C-88291</Popup>
            </Marker>
            <Marker position={[-7.260445, 112.778845]} icon={customIcon}>
              <Popup>Courier C-88292</Popup>
            </Marker>
          </MapContainer>
        </div>
        <div className="absolute bottom-20 left-0 w-full p-5 z-10 pointer-events-none">
          <div className="bg-white p-4 rounded-2xl border border-zinc-200 shadow-lg pointer-events-auto flex justify-around">
            <button className="flex flex-col items-center">
              <Crosshair size={20} className="text-zinc-950 mb-1" />
              <span className="text-[10px] font-bold uppercase tracking-widest">Focus</span>
            </button>
            <button className="flex flex-col items-center">
              <Phone size={20} className="text-zinc-950 mb-1" />
              <span className="text-[10px] font-bold uppercase tracking-widest">Contact</span>
            </button>
            <button className="flex flex-col items-center">
              <User size={20} className="text-zinc-950 mb-1" />
              <span className="text-[10px] font-bold uppercase tracking-widest">Details</span>
            </button>
          </div>
        </div>
      </div>
    );
  };

  const DispatcherAssignmentsScreen = () => (
    <div className="min-h-screen bg-white pb-24">
      <Header title="Package Assignment" backTo="dispatcherDashboard" />
      <div className="p-5 space-y-4">
        {[1, 2, 3].map(i => (
          <div key={i} className="bg-white p-5 border border-zinc-200 rounded-3xl shadow-sm">
             <div className="flex justify-between items-center mb-3">
               <span className="text-[10px] font-bold uppercase tracking-widest text-zinc-500">PKG-00{i+4}</span>
               <span className="bg-zinc-50 border border-zinc-200 text-zinc-950 text-[10px] px-3 py-1 rounded-full font-bold uppercase tracking-widest">Courier C-8829{i}</span>
             </div>
             <p className="text-[14px] text-zinc-600 mb-4 truncate">Jl. Sudirman No. {i*10}</p>
             <div className="flex space-x-3">
               <button className="h-12 flex-1 border border-zinc-200 bg-white text-zinc-950 rounded-2xl text-[12px] font-bold uppercase tracking-widest flex items-center justify-center hover:bg-zinc-50 shadow-sm">
                 Reassign
               </button>
               <button className="h-12 w-12 border border-red-200 bg-red-50 text-red-500 rounded-2xl flex items-center justify-center hover:bg-red-100 shadow-sm">
                 <X size={18} />
               </button>
             </div>
          </div>
        ))}
      </div>
    </div>
  );

  const DispatcherCenterScreen = () => (
    <div className="min-h-screen bg-zinc-50 pb-24">
      <Header title="Incident & SOS Center" />
      <div className="p-5 space-y-4">
        <h3 className="text-[12px] font-bold tracking-widest uppercase text-zinc-500 ml-1">Active Incidents</h3>
        <div className="bg-white border border-zinc-200 rounded-3xl p-5 shadow-sm">
          <div className="flex justify-between items-start mb-2">
            <span className="text-[14px] font-bold text-zinc-950">Route Blocked</span>
            <span className="text-[10px] font-bold uppercase text-zinc-500">10 mins ago</span>
          </div>
          <p className="text-[13px] text-zinc-600 mb-4">Courier C-88291 reported route blockage due to construction.</p>
          <div className="flex space-x-2">
            <button className="h-10 flex-1 bg-zinc-950 text-white rounded-xl text-[11px] font-bold uppercase tracking-widest">Trigger Re-route</button>
            <button className="h-10 flex-1 bg-white border border-zinc-200 text-zinc-950 rounded-xl text-[11px] font-bold uppercase tracking-widest">Notify Couriers</button>
          </div>
        </div>

        <h3 className="text-[12px] font-bold tracking-widest uppercase text-zinc-500 ml-1 mt-6">SOS Alerts</h3>
        <div className="bg-red-50 border border-red-200 rounded-3xl p-5 shadow-sm">
          <div className="flex items-center text-red-600 mb-2 font-bold uppercase tracking-widest text-[12px]">
            <AlertOctagon size={18} className="mr-2" /> Critical Emergency
          </div>
          <p className="text-[13px] text-zinc-800 mb-4">Courier C-88293 triggered SOS. Vehicle breakdown.</p>
          <div className="flex flex-col space-y-2">
            <button className="h-12 w-full bg-red-600 text-white rounded-xl text-[11px] font-bold uppercase tracking-widest flex items-center justify-center">Dispatch Support</button>
            <button className="h-12 w-full bg-white border border-red-200 text-red-600 rounded-xl text-[11px] font-bold uppercase tracking-widest flex items-center justify-center">Freeze Route & Reassign</button>
          </div>
        </div>
      </div>
    </div>
  );

  const DispatcherAnalyticsScreen = () => (
    <div className="min-h-screen bg-zinc-50 pb-24">
      <Header title="Analytics & Reports" backTo="dispatcherDashboard" />
      <div className="p-5 space-y-4">
        <div className="bg-white p-6 border border-zinc-200 rounded-3xl shadow-sm flex flex-col items-center">
          <h3 className="text-[12px] font-bold uppercase tracking-widest text-zinc-500 mb-2">Delivery Success Rate</h3>
          <p className="text-[48px] font-bold text-zinc-950 tracking-tighter mb-5">96.5%</p>
          <div className="w-full bg-zinc-100 h-2 rounded-full overflow-hidden">
            <div className="bg-zinc-950 h-2 rounded-full" style={{width: '96.5%'}}></div>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-4">
           <div className="bg-white p-5 border border-zinc-200 rounded-3xl flex flex-col items-start shadow-sm">
             <BarChart2 className="text-zinc-950 mb-4" size={24} strokeWidth={1.5} />
             <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-1">Avg Time/Drop</p>
             <p className="text-[20px] font-bold text-zinc-950">4.5 min</p>
           </div>
           <div className="bg-white p-5 border border-zinc-200 rounded-3xl flex flex-col items-start shadow-sm">
             <Activity className="text-zinc-950 mb-4" size={24} strokeWidth={1.5} />
             <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500 mb-1">AI Resolve Rate</p>
             <p className="text-[20px] font-bold text-zinc-950">88%</p>
           </div>
        </div>
        <div className="bg-white border border-zinc-200 p-6 rounded-3xl shadow-sm">
          <h4 className="text-[14px] font-bold text-zinc-950 mb-4 border-b border-zinc-100 pb-3">Courier Performance</h4>
          <div className="space-y-4">
            {[1, 2, 3].map(i => (
              <div key={i} className="flex justify-between items-center">
                <div>
                  <p className="text-[13px] font-bold text-zinc-950">Courier C-8829{i}</p>
                  <p className="text-[10px] font-bold uppercase tracking-widest text-zinc-500">{(100 - i * 2)} Drops</p>
                </div>
                <span className="text-[12px] font-bold text-green-600 bg-green-50 px-2 py-1 rounded-md">{98 - i}%</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );

  const IncidentDetailScreen = () => (
    <div className="min-h-screen bg-zinc-50 pb-24">
      <Header title="Fleet Incidents" backTo="dashboard" />
      <div className="p-5 space-y-4">
        <h2 className="text-[16px] font-bold text-zinc-950 mb-2">Laporan Rekan Kurir</h2>
        <p className="text-[13px] text-zinc-600 mb-6 leading-relaxed">Peringatan kondisi jalan dan insiden yang dilaporkan oleh kurir lain di sekitar Anda.</p>
        
        <div className="bg-white p-5 border border-red-200 rounded-3xl shadow-sm relative overflow-hidden">
          <div className="absolute top-0 left-0 w-1 h-full bg-red-500"></div>
          <div className="flex justify-between items-start mb-2">
            <span className="text-[14px] font-bold text-zinc-950">Route Blocked</span>
            <span className="text-[10px] font-bold uppercase tracking-widest text-zinc-500">10 min ago</span>
          </div>
          <p className="text-[13px] text-zinc-600 mb-3">Jalan Margorejo Indah ditutup sementara karena perbaikan aspal. Mohon cari jalur alternatif.</p>
          <div className="flex items-center text-[10px] font-bold uppercase tracking-widest text-zinc-500">
             <User size={12} className="mr-1" /> Reported by C-88291
          </div>
        </div>

        <div className="bg-white p-5 border border-zinc-200 rounded-3xl shadow-sm relative overflow-hidden">
          <div className="absolute top-0 left-0 w-1 h-full bg-yellow-500"></div>
          <div className="flex justify-between items-start mb-2">
            <span className="text-[14px] font-bold text-zinc-950">Heavy Traffic</span>
            <span className="text-[10px] font-bold uppercase tracking-widest text-zinc-500">45 min ago</span>
          </div>
          <p className="text-[13px] text-zinc-600 mb-3">Macet panjang di area Jemursari akibat kecelakaan kecil. Estimasi delay 15-20 menit.</p>
          <div className="flex items-center text-[10px] font-bold uppercase tracking-widest text-zinc-500">
             <User size={12} className="mr-1" /> Reported by C-88214
          </div>
        </div>
      </div>
    </div>
  );

  // --- HELPERS ---
  
  const Header = ({ title, backTo, rightIcon, onRightClick }) => (
    <div className="bg-white border-b border-zinc-200 p-4 flex items-center justify-between sticky top-0 z-20">
      {backTo ? (
        <button onClick={() => navigate(backTo)} className="p-2 -ml-2 text-zinc-950 active:bg-zinc-50 rounded-full transition-colors"><ChevronLeft size={24} /></button>
      ) : <div className="w-10"></div>}
      <h1 className="text-[14px] font-bold uppercase tracking-widest text-zinc-950">{title}</h1>
      {rightIcon ? <button onClick={onRightClick} className="p-2 -mr-2 text-zinc-950 active:bg-zinc-50 rounded-full transition-colors">{rightIcon}</button> : <div className="w-10"></div>}
    </div>
  );

  const BottomNav = () => {
    // Check if the current screen should show bottom nav
    const isVisible = ['dashboard', 'manifest', 'mapNav', 'notifications', 'profile', 'dispatcherDashboard', 'dispatcherLiveMap', 'dispatcherAssignments', 'dispatcherCenter', 'dispatcherAnalytics'].includes(currentScreen);
    if (!isVisible) return null;

    if (userRole === 'dispatcher') {
      const navItems = [
        { id: 'dispatcherDashboard', icon: <Box size={22} />, label: 'Home' },
        { id: 'dispatcherLiveMap', icon: <MapIcon size={22} />, label: 'Live Map' },
        { id: 'dispatcherAssignments', icon: <List size={22} />, label: 'Assign' },
        { id: 'dispatcherCenter', icon: <ShieldAlert size={22} />, label: 'Center' },
        { id: 'dispatcherAnalytics', icon: <BarChart2 size={22} />, label: 'Reports' },
      ];

      return (
        <div className="fixed bottom-0 w-full max-w-md bg-white border-t border-zinc-200 flex justify-around p-2 h-[72px] z-30 pb-safe">
          {navItems.map(item => {
            const isActive = currentScreen === item.id;
            return (
              <button 
                key={item.id} 
                onClick={() => navigate(item.id)}
                className={`flex flex-col items-center justify-center flex-1 transition-colors rounded-xl mx-1 ${isActive ? 'text-zinc-950 bg-zinc-50' : 'text-zinc-400 hover:text-zinc-600 hover:bg-zinc-50/50'}`}
              >
                {React.cloneElement(item.icon, { strokeWidth: isActive ? 2.5 : 1.5 })}
                <span className="text-[10px] mt-1.5 font-bold uppercase tracking-widest truncate max-w-full">{item.label}</span>
              </button>
            )
          })}
        </div>
      );
    } else {
      const navItems = [
        { id: 'dashboard', icon: <Box size={22} />, label: 'Home' },
        { id: 'manifest', icon: <Package size={22} />, label: 'Manifest' },
        { id: 'mapNav', icon: <MapIcon size={22} />, label: 'Map' },
        { id: 'profile', icon: <User size={22} />, label: 'Profile' },
      ];

      return (
        <div className="fixed bottom-0 w-full max-w-md bg-white border-t border-zinc-200 flex justify-between items-center px-1 h-[72px] z-30 pb-safe">
          {navItems.map((item, index) => {
            const isActive = currentScreen === item.id;
            return (
              <React.Fragment key={item.id}>
                {index === 2 && (
                  <div className="relative -top-6 flex justify-center w-14 flex-shrink-0">
                    <button 
                      onClick={() => navigate('scanner')}
                      className="w-14 h-14 bg-zinc-950 text-white rounded-full flex items-center justify-center shadow-[0_4px_20px_rgba(0,0,0,0.3)] active:scale-95 transition-transform"
                    >
                      <Scan size={24} strokeWidth={2} />
                    </button>
                  </div>
                )}
                <button 
                  onClick={() => navigate(item.id)}
                  className={`flex flex-col items-center justify-center flex-1 transition-colors rounded-xl mx-0.5 ${isActive ? 'text-zinc-950 bg-zinc-50' : 'text-zinc-400 hover:text-zinc-600 hover:bg-zinc-50/50'}`}
                >
                  {React.cloneElement(item.icon, { strokeWidth: isActive ? 2.5 : 1.5 })}
                  <span className="text-[9px] mt-1.5 font-bold uppercase tracking-widest truncate max-w-full">{item.label}</span>
                </button>
              </React.Fragment>
            )
          })}
        </div>
      );
    }
  };

  const Toast = () => {
    if (!toast) return null;
    return (
      <div className="fixed top-6 left-1/2 transform -translate-x-1/2 z-50 animate-slideDown w-11/12 max-w-sm">
        <div className="p-4 border border-zinc-800 shadow-xl flex items-start text-[13px] font-bold tracking-wide rounded-2xl bg-zinc-950 text-white">
          {toast.type === 'error' ? <AlertTriangle size={18} className="mr-3 mt-0.5 text-red-500 flex-shrink-0"/> : <CheckCircle size={18} className="mr-3 mt-0.5 text-white flex-shrink-0"/>}
          {toast.msg}
        </div>
      </div>
    );
  };

  // --- RENDER ROUTER ---
  
  const renderScreen = () => {
    switch(currentScreen) {
      case 'splash': return <SplashScreen />;
      case 'login': return <LoginScreen />;
      case 'forgotPassword': return <ForgotPasswordScreen />;
      case 'dashboard': return <DashboardScreen />;
      case 'scanner': return <ScannerScreen />;
      case 'manifest': return <ManifestScreen />;
      case 'mapNav': return <MapNavScreen />;
      case 'deliveryDetail': return <DeliveryDetailScreen />;
      case 'pod': return <PoDScreen />;
      case 'history': return <HistoryScreen />;
      case 'notifications': return <NotificationsScreen />; // Still called notifications, UI title is Logs
      case 'profile': return <ProfileScreen />;
      case 'help': return <HelpScreen />;
      case 'settings': return <SettingsScreen />;
      case 'clarification': return <ClarificationScreen />;
      case 'routeSummary': return <RouteSummaryScreen />;
      case 'incidentReport': return <IncidentReportScreen />;
      case 'syncManager': return <SyncManagerScreen />;
      case 'dispatcherDashboard': return <DispatcherDashboardScreen />;
      case 'dispatcherLiveMap': return <DispatcherLiveMapScreen />;
      case 'dispatcherAssignments': return <DispatcherAssignmentsScreen />;
      case 'dispatcherCenter': return <DispatcherCenterScreen />;
      case 'dispatcherAnalytics': return <DispatcherAnalyticsScreen />;
      case 'incidentDetail': return <IncidentDetailScreen />;
      default: return userRole === 'dispatcher' ? <DispatcherDashboardScreen /> : <DashboardScreen />;
    }
  };

  return (
    <div className="flex justify-center bg-zinc-900 min-h-screen overflow-hidden">
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
        
        * {
          font-family: 'Inter', sans-serif;
          box-sizing: border-box;
        }

        html, body {
          overflow-x: hidden;
          width: 100%;
          margin: 0;
          padding: 0;
        }
        
        @keyframes slideUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
        @keyframes slideDown { from { transform: translateY(-100%); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        @keyframes scan { 0% { top: 0; } 50% { top: 100%; } 100% { top: 0; } }
        .animate-slideUp { animation: slideUp 0.3s ease-out forwards; }
        .animate-slideDown { animation: slideDown 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
        .pb-safe { padding-bottom: env(safe-area-inset-bottom, 0px); }
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
      `}</style>
      
      <div className="w-full max-w-md bg-zinc-50 relative overflow-hidden h-screen flex flex-col border-x border-zinc-800 shadow-none">
        <Toast />
        <div className="flex-1 overflow-y-auto overflow-x-hidden no-scrollbar bg-zinc-50 w-full">
           {renderScreen()}
        </div>
        <BottomNav />
      </div>
    </div>
  );
}





Untuk app.css 


.App {
  text-align: center;
}

.App-logo {
  height: 40vmin;
  pointer-events: none;
}

@media (prefers-reduced-motion: no-preference) {
  .App-logo {
    animation: App-logo-spin infinite 20s linear;
  }
}

.App-header {
  background-color: #282c34;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
  color: white;
}

.App-link {
  color: #61dafb;
}

@keyframes App-logo-spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
