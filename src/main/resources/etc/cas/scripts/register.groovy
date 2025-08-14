@Grab('org.mindrot:jbcrypt:0.4')
import org.mindrot.jbcrypt.BCrypt
import java.sql.*
import org.slf4j.LoggerFactory

def logger = LoggerFactory.getLogger("CAS-Groovy-Provisioning")

def attrs = attributes  // payload: must include 'username', 'password', 'email'

def username = attrs['username'] ?: attrs['user']
def email = attrs['email']
def plainPassword = attrs['password']

if (!username || !plainPassword) {
    throw new IllegalArgumentException("Missing username or password for provisioning")
}

// Hash the password with BCrypt work factor 10
def salt = BCrypt.gensalt(10)
def hashedPassword = BCrypt.hashpw(plainPassword, salt)
logger.info("Hashed password for user {}", username)

def ds = new com.zaxxer.hikari.HikariDataSource()
ds.jdbcUrl = "jdbc:postgresql://db-host:5432/your_db"
ds.username = "cas_user"
ds.password = "cas_password"

logger.info("Provisioning user {}", username)

def sql = '''
  INSERT INTO users(username, password, email, enabled, expired)
  VALUES (?, ?, ?, TRUE, FALSE)
  ON CONFLICT (username) DO NOTHING
'''

def conn = ds.getConnection()
try {
    def stmt = conn.prepareStatement(sql)
    stmt.setString(1, username)
    stmt.setString(2, hashedPassword)
    stmt.setString(3, email)
    def count = stmt.executeUpdate()
    logger.info("Rows inserted: {}", count)
} finally {
    conn.close()
}

return attrs
