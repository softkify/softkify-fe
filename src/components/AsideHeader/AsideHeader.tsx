import React from 'react';
import { Link } from 'react-router-dom';
import { navbarItems } from './data';
import type { AsideHeaderProps } from './types';

const AsideHeader: React.FC<AsideHeaderProps> = ({ onAction }) => {
  return (
    <aside className="mt-12 p-5">
      <Link to="/" className="w-40 block" onClick={onAction}>
        <img src="/softkify-logo.jpeg" alt="Logo" className="w-full h-auto object-contain" />
      </Link>
      <p>soy el cambio</p>
      <nav>
        <ul>
          {navbarItems.map((item, index) => (
            <li key={index} className="mt-4">
              <Link to={item.href} onClick={onAction}>{item.label}</Link>
            </li>
          ))}
        </ul>
      </nav>
    </aside>
  );
};

export default AsideHeader;
