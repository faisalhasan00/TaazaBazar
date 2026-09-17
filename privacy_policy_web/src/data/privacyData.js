export const privacySections = [
  {
    id: "overview",
    title: "1. Overview & Scope",
    content: `
      Welcome to **TaazaBazar** ("App", "we", "us", or "our"), the mobile farm-fresh grocery ordering application operating under package **com.taazabazar.app**.

      We are dedicated to respecting and protecting your privacy. This Privacy Policy explains what information we collect, how it is used, how it is stored, and your rights regarding your personal data when using the TaazaBazar mobile app.

      This policy applies to all users accessing or placing orders through TaazaBazar.
    `
  },
  {
    id: "data-collected",
    title: "2. Information We Collect",
    content: `
      We collect only the minimum information necessary to process your grocery orders, calculate delivery fees, provide customer support, and communicate order milestones:

      - **Account Identifiers**: Your mobile phone number (used for One-Time Password verification), name, optional email address, and Firebase Authentication user identifier (UID).
      - **Delivery Addresses**: Complete street address, apartment/building name, floor, landmark, city, and postal PIN code entered for delivery drop-offs.
      - **Location Information**: Approximate and precise device coordinates (GPS) solely collected in the foreground when you tap "Use Current Location" to assist with address entry. We do NOT collect location in the background or track your continuous movement.
      - **Order & Transaction Data**: Purchased items, item quantities, subtotal, delivery fee, applied coupon codes, order status, chosen payment method (Cash on Delivery or Razorpay), and payment transaction identifiers.
      - **Device & Notification Identifiers**: Firebase Cloud Messaging (FCM) registration tokens and notification preferences stored to deliver transactional delivery status alerts and morning harvest updates.
      - **Customer Inquiries**: Communications, messages, and feedback submitted to TaazaBazar Customer Support.
    `
  },
  {
    id: "data-usage",
    title: "3. How We Use Your Information",
    content: `
      We process your personal information strictly for legitimate operational purposes:
      
      1. **Order Fulfillment**: Sorting, grading, packing, and dispatching fresh fruits, vegetables, and groceries from our fulfillment hubs.
      2. **Doorstep Delivery**: Providing delivery coordinates, address details, and contact numbers to delivery personnel solely for active order drop-offs.
      3. **Order Status Notifications**: Sending automated push notifications regarding order confirmation, preparation, dispatch, and delivery.
      4. **Payment & Refund Processing**: Facilitating secure payment verification and issuing refunds for eligible cancelled orders.
      5. **Customer Support**: Responding to questions, resolving delivery queries, and addressing quality reports.
    `
  },
  {
    id: "device-permissions",
    title: "4. Device Permissions Requested",
    content: `
      TaazaBazar requests only standard runtime permissions required for core app functions:
      
      - **Internet Access** (\`android.permission.INTERNET\`, \`ACCESS_NETWORK_STATE\`): Required to communicate with secure catalog and ordering services.
      - **Location** (\`ACCESS_FINE_LOCATION\`, \`ACCESS_COARSE_LOCATION\` - *Optional*): Used exclusively in the foreground when you choose to auto-detect your delivery address. You can always enter your address manually without granting GPS access.
      - **Notifications** (\`POST_NOTIFICATIONS\` - *Android 13+*): To deliver real-time order status updates and delivery notifications.
    `
  },
  {
    id: "data-sharing",
    title: "5. Third-Party Services & Data Sharing",
    content: `
      **We do not sell, rent, or trade your personal data to any third party for marketing or advertising.**
      
      We share data only with trusted technical service providers necessary to provide our services:
      - **Google Firebase**: Authentication, Cloud Firestore database storage, and Firebase Cloud Messaging for push notification delivery.
      - **Razorpay**: Secure online payment checkout, signature verification, and automated refund processing. TaazaBazar does not store your credit/debit card numbers, CVVs, or banking credentials on its servers.
      - **Delivery Personnel**: Recipient name, delivery address, and contact number during active order fulfillment.
      - **Legal Authorities**: Where required by applicable law, court order, or governmental regulation.
    `
  },
  {
    id: "data-retention",
    title: "6. Data Retention & Security Measures",
    content: `
      - **Security Measures**: We use appropriate technical and organizational measures designed to protect your information. Data in transit is secured using industry-standard TLS/HTTPS encryption.
      - **Data Retention**: We retain personal information for as long as reasonably necessary to provide our services, maintain order history for digital invoices, comply with applicable statutory obligations, and resolve disputes.
    `
  },
  {
    id: "user-rights-deletion",
    title: "7. User Rights & Account Deletion",
    content: `
      You have the right to review, update, or request deletion of your personal data:
      
      - **Review & Update**: You can update your name and saved delivery addresses anytime in the **Profile** section of the app.
      - **Notification Controls**: You can customize notification preferences under Profile → Settings → Push Notifications.
      - **Account & Data Deletion**: To request deletion of your account, saved addresses, and device tokens, please send an email to **care@taazabazar.in** with your registered mobile number and the subject *"Account Deletion Request"*. Deletion requests are processed manually by our customer support team upon identity verification.
    `
  },
  {
    id: "children-privacy",
    title: "8. Children's Privacy",
    content: `
      TaazaBazar is not intended for use by children under the age of 18. We do not knowingly collect personal identifiable information from minors. If you believe a child has provided us with personal information, please contact Customer Support for prompt deletion.
    `
  },
  {
    id: "policy-updates",
    title: "9. Policy Updates",
    content: `
      We may periodically update this Privacy Policy to reflect operational or regulatory changes. The updated version will be posted with an updated "Last Updated" date. We encourage you to review this policy periodically.
    `
  },
  {
    id: "contact-support",
    title: "10. Contact & Support Information",
    content: `
      For any questions, feedback, or support regarding our privacy practices or data handling, please contact:

      - **Application**: TaazaBazar (\`com.taazabazar.app\`)
      - **Support Email**: **care@taazabazar.in**
      - **Customer Care Phone**: **+91 98765 12340**
      - **Operating Hours**: Mon – Sun: 6:00 AM – 9:00 PM IST
    `
  }
];
