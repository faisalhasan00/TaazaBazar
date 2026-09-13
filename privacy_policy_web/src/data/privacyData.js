export const privacySections = [
  {
    id: "overview",
    title: "1. Overview & Identity of Developer",
    content: `
      Welcome to **TaazaBazar** ("App", "we", "us", or "our"), operated as the official mobile grocery ordering service under application package **com.taazabazar.app**. 
      
      We are committed to respecting your privacy, protecting your personal data, and providing transparent information regarding our practices in compliance with the **Information Technology (Reasonable Security Practices and Procedures and Sensitive Personal Data or Information) Rules, 2011**, the **Digital Personal Data Protection Act (DPDPA), 2023**, and the **Google Play Developer Policy on User Data & Data Safety**.
      
      This Privacy Policy applies to all users who download, access, or use the TaazaBazar mobile application or associated web endpoints.
    `
  },
  {
    id: "data-collected",
    title: "2. Information We Collect",
    content: `
      We only collect information necessary to fulfill your grocery orders, calculate delivery times, provide customer support, and improve our services:

      - **Personal Identification Data**: Name, mobile phone number, email address (when provided during registration/login).
      - **Delivery & Address Information**: Street address, apartment/house number, floor, landmark, city, state, postal PIN code, and optional delivery instructions.
      - **Order & Transaction History**: Details of items purchased, order totals, applied coupons (e.g., TAAZA50), chosen delivery time slots, payment method type (COD, UPI, Card), and order status.
      - **Location Information**: Approximate and precise device coordinates (GPS) solely collected when you actively grant location permission to set or pinpoint your delivery address on the map.
      - **Device & Technical Information**: Device model, operating system version, unique device identifiers, IP address, network carrier, and crash logs to ensure app performance and prevent fraud.
      - **Customer Support Interactions**: Messages, chats, and feedback submitted to TaazaBazar Customer Care.
    `
  },
  {
    id: "data-usage",
    title: "3. How We Use Your Information",
    content: `
      We process your personal information strictly for legitimate business and service delivery purposes:
      
      1. **Order Processing & Fulfillment**: Dispatching farm-fresh vegetables, dairy, and grocery items to your designated doorstep.
      2. **Rider Assignment & Route Optimization**: Sharing the delivery address, contact name, and phone number with assigned **Taaza Super Riders** solely for the active order drop-off.
      3. **Order Status Notifications**: Sending transactional SMS, push notifications, and OTP codes for account authentication and live delivery milestone tracking.
      4. **Payment Verification**: Processing bills and issuing refunds or wallet credits for cancellations and damaged items.
      5. **Membership Perks**: Administering **Taaza Pass** benefits including unlimited free delivery and member discounts.
      6. **Security & Fraud Prevention**: Detecting and preventing fake accounts, fraudulent transactions, and unauthorized access.
    `
  },
  {
    id: "device-permissions",
    title: "4. Device Permissions Requested",
    content: `
      TaazaBazar requests only minimum runtime permissions strictly required for core functionality:
      
      - **INTERNET / Network State** (\`android.permission.INTERNET\`): Required to connect with our secure catalog API, submit orders, and fetch live tracking updates.
      - **Location** (\`ACCESS_FINE_LOCATION\` / \`ACCESS_COARSE_LOCATION\` - *Optional*): Used exclusively while the app is active to automatically populate your current address and locate nearby delivery hubs. You can manually enter your address without granting GPS access.
      - **Notifications** (\`POST_NOTIFICATIONS\` - *Android 13+*): To send critical order status updates (e.g., "Out for Delivery", "Rider Arrived", "OTP").
    `
  },
  {
    id: "data-sharing",
    title: "5. Third-Party Sharing & Service Providers",
    content: `
      **We do not sell, rent, or trade your personal data to any third party for marketing or advertising.**
      
      We share data only with trusted service partners under strict confidentiality agreements:
      - **Delivery Logistics Partners & Riders**: Only recipient name, delivery coordinates, address, and delivery PIN are shared during active deliveries.
      - **Payment Gateways (UPI, Cards, Net Banking)**: Transaction amounts and tokenized tokens handled by PCI-DSS compliant banking partners (Razorpay / Stripe / NPCI). We never store raw card CVV numbers.
      - **Cloud Infrastructure & Database**: Hosted on secure, encrypted Google Cloud Platform (GCP) and ISO/IEC 27001 certified data centers located in India.
      - **Legal Authorities**: When mandated by applicable Indian law, court order, or governmental enforcement agency.
    `
  },
  {
    id: "data-retention",
    title: "6. Data Retention & Security Safeguards",
    content: `
      - **Encryption**: All data transmitted between your device and our servers is secured using industry-standard **TLS 1.3 / HTTPS encryption**.
      - **Storage Security**: Stored personal records are guarded with AES-256 database encryption, role-based access control (RBAC), and continuous vulnerability monitoring.
      - **Retention Period**: We retain your personal data as long as your TaazaBazar account is active, or as necessary to comply with legal tax, invoicing, and accounting requirements (typically 5 to 7 years under Indian Goods and Services Tax laws).
    `
  },
  {
    id: "user-rights-deletion",
    title: "7. User Rights & Account / Data Deletion",
    content: `
      In accordance with Google Play User Data Policy and the DPDPA, you retain complete control over your data:
      
      - **Access & Correction**: You can review and update your profile name, email, and saved addresses directly in the **Profile** section of the app.
      - **Consent Revocation**: You can withdraw location or notification permissions anytime in your device settings.
      - **Account & Data Deletion Request**: You have the right to request permanent deletion of your TaazaBazar account and associated personal data.
      
      To submit an account deletion request:
      1. Use the **[Data Deletion Request Form](#data-deletion)** on this page.
      2. Or send an email to **care@taazabazar.in** with the subject *"Account Deletion Request"* and your registered mobile number.
      3. Your personal identifiers and addresses will be permanently purged within **7 business days**.
    `
  },
  {
    id: "children-privacy",
    title: "8. Children's Privacy",
    content: `
      TaazaBazar is not directed toward children under the age of 18. We do not knowingly collect personal identifiable information from minors. If you believe a child has provided us with personal information, please contact us immediately for prompt deletion.
    `
  },
  {
    id: "policy-updates",
    title: "9. Changes to This Privacy Policy",
    content: `
      We may periodically update this policy to reflect changes in our legal obligations or application features. When significant changes occur, we will update the "Effective Date" at the top and notify users via an in-app prompt. Continued use of TaazaBazar following such notification constitutes acceptance.
    `
  },
  {
    id: "grievance-officer",
    title: "10. Grievance Officer & Contact Information",
    content: `
      If you have any questions, concerns, or grievances regarding our privacy practices or data handling, please contact our designated Grievance Officer:

      - **Officer Name**: Grievance Redressal Desk
      - **Organization**: TaazaBazar Online Grocery Private Limited
      - **Official Email**: **care@taazabazar.in** / **grievance@taazabazar.in**
      - **Support Desk**: 24x7 In-App Chat Support
      - **App Package**: \`com.taazabazar.app\`
      - **Operating Region**: Bengaluru, Karnataka, India - 560038
    `
  }
];
