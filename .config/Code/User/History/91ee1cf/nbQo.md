# Threat Model - DevSecOps Sample Application

## 1. Overview
This threat model identifies and mitigates potential security risks in the sample application.
The app consists of a frontend (user interface), backend API, and a database.

---

## 2. System Components
- Frontend: Web interface for users
- Backend: API that processes user data
- Database: Stores user credentials and data
- External Services: Payment gateway / external API

---

## 3. Data Flow Diagram (DFD)
User -> Frontend -> Backend API -> Database

---

## 4. Threat Analysis (Using STRIDE)

| Category | Description | Example | Mitigation |
|------------|-------------|----------|-------------|
|**S**poofing | Pretending to be a valid user | Attacker logs in with fake credentials | Use MFA and strong auth |
|**T**ampering | Altering requests or data | Changing POST data in transit | Use HTTPS + input validation |
|**R**epudiation | Denying actions | User denies submitting data | Enable logging and audit trails | 
|**I**nformation Disclosure | Leaking sensitive data | Exposed API keys | Encrypt and hide secrets |
|**E**levation of Previlage | Getting admin rights | Regular user gains admin access | Role-based access control

---

## 5. Identified Vulnerabilities
- Missing input validation
- No HTTPS enforcement
- No authentication for admin routes

---

## 6. Mitigation Plan 
- Implementing HTTPS using TLS certificates
- Validate all user input (server-side)
- Add authentication middleware for protected routes
- Store passswords hashed (bcrypt)
- Apply principle of least privilage

---

## 7. Conclusion
The threat model helps identify and mitigate key security risks before deployment.
Future scans (CodeQL, Gitleaks) will validate that mitigations are effective. 