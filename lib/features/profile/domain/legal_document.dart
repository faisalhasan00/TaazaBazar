/// Model representing a section in a legal policy document
class LegalSection {
  final String title;
  final String content;

  const LegalSection({
    required this.title,
    required this.content,
  });
}

/// Model representing an authoritative legal document in TaazaBazar
class LegalDocument {
  final String id;
  final String title;
  final String lastUpdated;
  final String effectiveDate;
  final List<LegalSection> sections;

  const LegalDocument({
    required this.id,
    required this.title,
    required this.lastUpdated,
    required this.effectiveDate,
    required this.sections,
  });
}

/// Authoritative in-app legal content repository based strictly on actual app functionality
class LegalRepository {
  LegalRepository._();

  static const String effectiveDate = 'September 14, 2026';
  static const String lastUpdatedDate = 'September 14, 2026';

  static const LegalDocument privacyPolicy = LegalDocument(
    id: 'privacy',
    title: 'Privacy Policy',
    effectiveDate: effectiveDate,
    lastUpdated: lastUpdatedDate,
    sections: [
      LegalSection(
        title: '1. Overview & Scope',
        content:
            'TaazaBazar is committed to protecting your privacy. This Privacy Policy discloses our data collection, usage, storage, and security practices for the TaazaBazar mobile application (com.taazabazar.app).\n\nWe process personal data solely as necessary to provide farm-fresh grocery ordering, payment settlement, customer support, and doorstep delivery services.',
      ),
      LegalSection(
        title: '2. Information We Collect',
        content:
            'We collect only information necessary to deliver our services:\n\n'
            '• Account Data: Your mobile phone number (used for secure OTP authentication), your name, optional email address, and unique Firebase Authentication user identifier (UID).\n\n'
            '• Delivery Address Data: Street address, flat/building name, landmark, city, and postal PIN code provided when adding or editing delivery addresses.\n\n'
            '• Location Data: Device GPS coordinates (latitude and longitude) collected strictly in the foreground when you tap "Use Current Location" to assist with address entry. We do NOT track location in the background.\n\n'
            '• Order & Transaction Details: Products ordered, quantities, subtotal, delivery fee, applied coupon codes, order status, payment gateway used (COD or Razorpay), and payment transaction IDs.\n\n'
            '• Device & Notification Data: Firebase Cloud Messaging (FCM) registration tokens and notification preferences stored to send delivery milestone alerts and morning harvest notifications.',
      ),
      LegalSection(
        title: '3. How We Use Your Information',
        content:
            'Your data is processed strictly for legitimate operational purposes:\n\n'
            '1. Fulfilling and packing your grocery orders at our fulfillment hubs.\n'
            '2. Facilitating doorstep delivery to your selected address.\n'
            '3. Sending transactional push notifications regarding order confirmation, dispatch, and delivery.\n'
            '4. Verifying payment signatures and initiating order cancellations or refunds.\n'
            '5. Providing customer care and resolving order inquiries.',
      ),
      LegalSection(
        title: '4. Third-Party Services & Infrastructure',
        content:
            'We utilize only trusted, industry-standard service providers strictly required to operate the application:\n\n'
            '• Firebase Authentication & Cloud Firestore (Google): Secure phone number authentication, user profiles, and order data storage.\n\n'
            '• Firebase Cloud Messaging (Google): Delivering transactional and opted-in push notifications.\n\n'
            '• Razorpay Payment Gateway: Secure payment checkout and automated refund processing for online payments. TaazaBazar does NOT collect or store your credit/debit card numbers, CVVs, or net banking passwords.',
      ),
      LegalSection(
        title: '5. Data Security & Storage',
        content:
            'We use appropriate technical and organizational measures designed to protect your information against unauthorized access, loss, or alteration. All communication between the app and server endpoints occurs over secure TLS/HTTPS encryption.',
      ),
      LegalSection(
        title: '6. Data Retention & Account Deletion',
        content:
            'We retain personal information for as long as reasonably necessary to fulfill orders, maintain order history for invoices, and comply with applicable statutory obligations.\n\n'
            'To request permanent deletion of your account and personal data, please contact Customer Support at care@taazabazar.in with your registered phone number. Account deletion requests are processed manually by our support team.',
      ),
    ],
  );

  static const LegalDocument termsAndConditions = LegalDocument(
    id: 'terms',
    title: 'Terms & Conditions',
    effectiveDate: effectiveDate,
    lastUpdated: lastUpdatedDate,
    sections: [
      LegalSection(
        title: '1. Acceptance of Terms',
        content:
            'By creating an account or placing an order on TaazaBazar, you agree to these Terms and Conditions. If you do not agree with any part of these terms, please discontinue use of the application.',
      ),
      LegalSection(
        title: '2. User Accounts & Verification',
        content:
            'You must register with a valid mobile phone number capable of receiving One-Time Passwords (OTP). You are responsible for maintaining the confidentiality of your session and account access.',
      ),
      LegalSection(
        title: '3. Products, Pricing & Availability',
        content:
            '• All catalog prices are displayed in Indian Rupees (₹) and include applicable taxes.\n\n'
            '• Farm produce availability may vary depending on harvest conditions and morning arrivals. In the event an ordered item is unavailable, you will be notified and appropriate refund/adjustments will be made.\n\n'
            '• Offers, coupons, and discounts are subject to the terms specified with each promotion.',
      ),
      LegalSection(
        title: '4. Delivery & Fulfillment',
        content:
            '• Standard deliveries are scheduled during designated morning slots (typically 6:00 AM – 8:00 AM).\n\n'
            '• Free delivery applies on orders meeting or exceeding ₹199. Orders below ₹199 incur a standard delivery fee of ₹25.\n\n'
            '• Delivery is subject to delivery address accessibility and serviceable operational zones.',
      ),
      LegalSection(
        title: '5. Payment Methods',
        content:
            'TaazaBazar supports Cash on Delivery (COD) and online payments (UPI, Cards, Net Banking) processed securely via Razorpay. Orders paid online must undergo server-side signature verification before being marked as paid.',
      ),
      LegalSection(
        title: '6. Customer Responsibilities & Conduct',
        content:
            'Customers agree to provide accurate delivery addresses and contact numbers. Fraudulent order placement, intentional payment tampering, or abusive conduct towards support personnel or delivery staff will result in account suspension.',
      ),
    ],
  );

  static const LegalDocument cancellationAndRefundPolicy = LegalDocument(
    id: 'cancellation_refund',
    title: 'Cancellation & Refund Policy',
    effectiveDate: effectiveDate,
    lastUpdated: lastUpdatedDate,
    sections: [
      LegalSection(
        title: '1. Order Cancellation Policy',
        content:
            '• Cancellation Window: You may cancel an order directly from the app ONLY while the order status is in the "Placed" stage.\n\n'
            '• Non-Cancellable Stages: Once farm produce harvesting, packing, or dispatch has commenced (order status advances to "Preparing", "Out for Delivery", or "Delivered"), orders cannot be cancelled through the app.',
      ),
      LegalSection(
        title: '2. Cash on Delivery (COD) Cancellations',
        content:
            'For Cash on Delivery orders cancelled in the "Placed" stage, the order status and payment status are updated to "Cancelled" immediately with zero payment liability.',
      ),
      LegalSection(
        title: '3. Online Payment (Razorpay) Refunds',
        content:
            '• When an online paid order is successfully cancelled in the "Placed" stage, an automated refund is initiated through Razorpay for the exact amount paid.\n\n'
            '• The refund record is linked to your order details with a unique Gateway Refund ID.\n\n'
            '• Refund processing time may depend on the payment provider and the customer\'s financial institution.',
      ),
      LegalSection(
        title: '4. Damaged or Quality Issue Reports',
        content:
            'If you receive an item with quality issues or damage, please contact Customer Care at care@taazabazar.in or +91 98765 12340 within 24 hours of delivery along with your Order ID for assistance.',
      ),
    ],
  );

  static const LegalDocument deliveryPolicy = LegalDocument(
    id: 'delivery',
    title: 'Delivery Policy',
    effectiveDate: effectiveDate,
    lastUpdated: lastUpdatedDate,
    sections: [
      LegalSection(
        title: '1. Morning Harvest Delivery Schedule',
        content:
            'Orders placed on TaazaBazar are fulfilled through our morning delivery slots (Tomorrow 6:00 AM – 8:00 AM). Produce is harvested, sorted, and dispatched directly from our farm hubs to ensure freshness.',
      ),
      LegalSection(
        title: '2. Delivery Fees & Free Delivery Threshold',
        content:
            '• Free Delivery: All orders with a subtotal of ₹199 or more qualify for FREE delivery.\n\n'
            '• Standard Delivery Fee: A delivery charge of ₹25 is applied to orders with a subtotal below ₹199.',
      ),
      LegalSection(
        title: '3. Serviceable Areas & Fulfillment Hubs',
        content:
            'Orders are dispatched from our primary fulfillment center (Sunrise Organic Farm, Shadnagar Hub) to serviceable residential and commercial zones. Estimated delivery timings depend on traffic conditions and operational factors.',
      ),
      LegalSection(
        title: '4. Delivery Address & Contact Requirements',
        content:
            'Please ensure your complete address (including house/flat number, street, and landmark) and an active contact number are provided. Delivery personnel will attempt delivery at the specified address during the allocated slot.',
      ),
    ],
  );

  static const LegalDocument dataDeletionGuide = LegalDocument(
    id: 'data_deletion',
    title: 'Account & Data Deletion',
    effectiveDate: effectiveDate,
    lastUpdated: lastUpdatedDate,
    sections: [
      LegalSection(
        title: '1. Your Right to Delete Your Data',
        content:
            'TaazaBazar respects your right to request deletion of your account and associated personal information. We do not engage in hidden data retention.',
      ),
      LegalSection(
        title: '2. How to Request Account Deletion',
        content:
            'To submit an account deletion request:\n\n'
            '1. Send an email to care@taazabazar.in from your registered email address (or mention your registered mobile number).\n'
            '2. Use the subject line: "Account Deletion Request - [Your Phone Number]".\n'
            '3. Our customer support team will verify your identity and process the deletion of your account profile, saved addresses, and device tokens.\n\n'
            'Note: Historical transaction receipts and invoices may be retained where required by applicable statutory and tax laws.',
      ),
    ],
  );
}
