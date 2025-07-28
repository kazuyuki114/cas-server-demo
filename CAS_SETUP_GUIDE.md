# CAS Server Setup Guide - From Scratch

This guide provides step-by-step instructions for setting up an Apereo CAS (Central Authentication Service) server from scratch, based on the overlay template approach.


## Step 1: Project Structure Setup

### 1.1 Download CAS Overlay Template
```bash
git clone https://github.com/apereo/cas-overlay-template.git
cd cas-overlay-template
```

### 1.2 Verify Project Structure
The project should have this basic structure:
```
cas-overlay-template/
├── build.gradle
├── gradle/
├── src/main/resources/
│   ├── application.yml
│   └── services/
├── etc/cas/
└── gradlew
```

## Step 2: SSL Configuration

### 2.1 Generate SSL Keystore
CAS requires SSL for production use. Generate a keystore:

```bash
# Create the keystore using Gradle task
./gradlew createKeystore -PcertDir=./etc/cas -PserverKeystore=thekeystore -PexportedServerCert=server.crt -PstoreType=JKS

# Copy keystore to resources directory
cp etc/cas/thekeystore src/main/resources/
```

### 2.2 Configure SSL in application.yml
```yaml
server:
  port: 8443
  ssl:
    enabled: true
    key-store: classpath:thekeystore
    key-store-password: changeit
    key-alias: cas
```

## Step 3: Basic Configuration

### 3.1 Create application.yml
Create `src/main/resources/application.yml` with basic configuration:

```yaml
cas:
  authn:
    accept:
      users: "casuser::Mellon"
      name: "Static Credentials"

  service-registry:
    core:
      init-from-json: true
    json:
      location: classpath:/services

  server:
    name: https://localhost:8443
    prefix: https://localhost:8443/cas

  # Disable encryption for development (enable for production)
  webflow:
    crypto:
      enabled: false

  tgc:
    crypto:
      enabled: false

server:
  port: 8443
  ssl:
    enabled: true
    key-store: classpath:thekeystore
    key-store-password: changeit
    key-alias: cas

logging:
  level:
    org.apereo.cas: DEBUG
    org.springframework.jdbc: DEBUG
    root: WARN
```

## Step 4: Service Registry Configuration

### 4.1 Create Services Directory
```bash
mkdir -p src/main/resources/services
```

### 4.2 Add Sample Service
Create `src/main/resources/services/sample-service.json`:

```json
{
  "@class": "org.apereo.cas.services.RegexRegisteredService",
  "serviceId": "https://apereo.github.io",
  "name": "Sample Service",
  "id": 1,
  "description": "A sample service for testing",
  "evaluationOrder": 1
}
```

## Step 5: Authentication Configuration

### 5.1 Static Users (Development)
For development, use static user authentication:

```yaml
cas:
  authn:
    accept:
      users: "casuser::Mellon"
      name: "Static Credentials"
```

### 5.2 Database Authentication (Production)
For production, configure database authentication:

```yaml
cas:
  authn:
    jdbc:
      query:
        - sql: "SELECT password FROM users WHERE username = ?"
          fieldPassword: "password"
          url: "jdbc:mysql://localhost:3306/cas"
          user: "casuser"
          password: "caspwd"
          driverClass: "com.mysql.cj.jdbc.Driver"
```

## Step 6: Encryption Configuration

### 6.1 For Development (No Encryption)
```yaml
cas:
  webflow:
    crypto:
      enabled: false
  tgc:
    crypto:
      enabled: false
```

## Step 7: Build and Run

### 7.1 Build the Application
```bash
./gradlew build
```

### 7.2 Run CAS Server
```bash
./gradlew run
```

The CAS server will be available at: `https://localhost:8443/cas`

## Step 8: Testing

### 8.1 Test Login
1. Open browser: `https://localhost:8443/cas`
2. Login with:
   - Username: `casuser`
   - Password: `Mellon`

This guide provides the foundation for setting up a CAS server. Customize the configuration based on your specific requirements and security needs. 
