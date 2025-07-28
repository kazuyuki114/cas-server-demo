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

### 8.2 Test Service Validation
Test service ticket validation:
```
https://localhost:8443/cas/serviceValidate?service=https://apereo.github.io&ticket=ST-xxx
```

## Step 9: Production Considerations

### 9.1 Security Hardening
- Enable encryption for webflow and TGC
- Use strong, unique encryption keys
- Configure proper SSL certificates
- Set up proper logging levels

### 9.2 Database Configuration
- Configure ticket registry (Redis, JDBC, etc.)
- Set up service registry database
- Configure audit logging

### 9.3 Monitoring
- Enable CAS metrics
- Configure health checks
- Set up monitoring endpoints

## Common Issues and Solutions

### Issue 1: Keystore Not Found
**Error**: `Could not load store from 'classpath:thekeystore'`
**Solution**: Ensure keystore is in `src/main/resources/` directory

### Issue 2: Encryption Algorithm Errors
**Error**: `AlgorithmParameterSpec not of GCMParameterSpec`
**Solution**: Disable encryption for development or use compatible keys

### Issue 3: SSL Certificate Issues
**Error**: Browser shows SSL warnings
**Solution**: Import the generated certificate into your truststore or use proper SSL certificates

## Advanced Configuration

### Custom Authentication
To add custom authentication methods, create configuration classes:

```java
@Configuration
public class CustomAuthenticationConfiguration {
    // Custom authentication configuration
}
```

### Custom Services
Add custom services by creating JSON files in `src/main/resources/services/`

### Custom Themes
Create custom themes in `src/main/resources/static/themes/`

## Deployment Options

### 1. Standalone JAR
```bash
./gradlew bootJar
java -jar build/libs/cas.war
```

### 2. Docker
```bash
./gradlew jibDockerBuild
docker run -p 8443:8443 cas-server
```

### 3. Kubernetes
Use the provided Helm charts in the `helm/` directory.

## Troubleshooting

### Enable Debug Logging
```yaml
logging:
  level:
    org.apereo.cas: DEBUG
```

### Check Application Status
- Health endpoint: `https://localhost:8443/cas/actuator/health`
- Info endpoint: `https://localhost:8443/cas/actuator/info`

### Common Commands
```bash
# Clean and rebuild
./gradlew clean build

# Run with debug
./gradlew run --debug-jvm

# Show CAS version
./gradlew casVersion
```

## Next Steps

1. **Customize Authentication**: Configure your preferred authentication methods
2. **Add Services**: Register your applications as CAS services
3. **Configure Logging**: Set up proper logging for your environment
4. **Security Hardening**: Implement production security measures
5. **Monitoring**: Set up monitoring and alerting

## Resources

- [CAS Documentation](https://apereo.github.io/cas)
- [CAS GitHub Repository](https://github.com/apereo/cas)
- [CAS Community](https://apereo.org/projects/cas)

---

This guide provides the foundation for setting up a CAS server. Customize the configuration based on your specific requirements and security needs. 