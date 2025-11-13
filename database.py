import sqlite3

def get_db_connection():
    """获取数据库连接"""
    conn = sqlite3.connect('user_auth.db')
    conn.row_factory = sqlite3.Row
    return conn