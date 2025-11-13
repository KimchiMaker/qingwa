from database import get_db_connection

def init_db():
    """初始化数据库表"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 检查users表是否存在
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='users'")
        users_table_exists = cursor.fetchone()
        
        if not users_table_exists:
            print("创建 users 表...")
            # 创建用户表
            cursor.execute('''
                CREATE TABLE users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT UNIQUE NOT NULL,
                    password TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
        
        # 检查movie表是否存在
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='movie'")
        movie_table_exists = cursor.fetchone()
        
        if not movie_table_exists:
            print("创建 movie 表...")
            # 创建movie表（为后续功能预留）
            cursor.execute('''
                CREATE TABLE movie (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL,
                    description TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
        
        conn.commit()
        conn.close()
        print("数据库表初始化完成")
        return True
    except Exception as e:
        print(f"初始化数据库失败: {str(e)}")
        return False

def add_user(username, password):
    """添加新用户"""
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            'INSERT INTO users (username, password) VALUES (?, ?)',
            (username, password)
        )
        conn.commit()
        user_id = cursor.lastrowid
        conn.close()
        return user_id
    except Exception as e:
        conn.close()
        raise e

def get_user_by_username(username):
    """根据用户名获取用户"""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM users WHERE username = ?', (username,))
    user = cursor.fetchone()
    conn.close()
    return user

def user_exists(username):
    """检查用户是否存在"""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT 1 FROM users WHERE username = ?', (username,))
    exists = cursor.fetchone() is not None
    conn.close()
    return exists