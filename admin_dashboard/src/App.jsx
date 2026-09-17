import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, useLocation } from 'react-router-dom';
import Sidebar from './components/Layout/Sidebar';
import Header from './components/Layout/Header';
import Dashboard from './pages/Dashboard';
import Products from './pages/Products';
import Orders from './pages/Orders';
import Categories from './pages/Categories';
import Subscriptions from './pages/Subscriptions';
import Coupons from './pages/Coupons';
import Banners from './pages/Banners';
import Members from './pages/Members';
import { orderService } from './services/orderService';

function AppContent() {
  const location = useLocation();
  const [activeOrdersCount, setActiveOrdersCount] = useState(0);
  const [isRefreshing, setIsRefreshing] = useState(false);

  useEffect(() => {
    const unsub = orderService.subscribeToOrders((orders) => {
      const active = orders.filter(o => ['placed', 'confirmed', 'packed', 'out_for_delivery'].includes(o.status));
      setActiveOrdersCount(active.length);
    });
    return () => unsub();
  }, []);

  const getPageInfo = () => {
    switch (location.pathname) {
      case '/':
        return { title: 'Executive Overview', subtitle: 'Real-time sales & store performance' };
      case '/orders':
        return { title: 'Live Orders Dispatch', subtitle: 'Process and track outgoing customer deliveries' };
      case '/members':
        return { title: 'Members & Customers', subtitle: 'Registered customer accounts, orders & subscriptions' };
      case '/products':
        return { title: 'Product & Stock Catalog', subtitle: 'Manage prices, inventory, and produce' };
      case '/categories':
        return { title: 'Store Categories', subtitle: 'Organize grocery catalog taxonomy' };
      case '/subscriptions':
        return { title: 'Daily Subscriptions', subtitle: 'Recurring morning & evening delivery plans' };
      case '/coupons':
        return { title: 'Discount Coupons', subtitle: 'Promotional codes and discounts' };
      case '/banners':
        return { title: 'Home Carousel Banners', subtitle: 'Hero visual promotions & advertisements' };
      default:
        return { title: 'TaazaBazar Admin', subtitle: 'Store Management Hub' };
    }
  };

  const handleRefresh = () => {
    setIsRefreshing(true);
    setTimeout(() => setIsRefreshing(false), 800);
  };

  const pageInfo = getPageInfo();

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden">
      {/* Fixed Left Sidebar */}
      <Sidebar orderCount={activeOrdersCount} />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        <Header 
          title={pageInfo.title} 
          subtitle={pageInfo.subtitle} 
          onRefresh={handleRefresh}
          isRefreshing={isRefreshing}
        />
        
        <main className="flex-1 pb-16">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/orders" element={<Orders />} />
            <Route path="/members" element={<Members />} />
            <Route path="/products" element={<Products />} />
            <Route path="/categories" element={<Categories />} />
            <Route path="/subscriptions" element={<Subscriptions />} />
            <Route path="/coupons" element={<Coupons />} />
            <Route path="/banners" element={<Banners />} />
          </Routes>
        </main>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <AppContent />
    </BrowserRouter>
  );
}
