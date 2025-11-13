from database import get_db_connection
import json
from datetime import datetime

def init_cinemas_table():
    """初始化影院表"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS cinemas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            price REAL NOT NULL,
            tags TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    conn.commit()
    conn.close()
    print("影院表初始化完成")

def add_cinema(name, address, price, tags=None):
    """添加新影院"""
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        # 将标签列表转换为JSON字符串
        tags_json = json.dumps(tags) if tags else '[]'
        
        cursor.execute(
            '''INSERT INTO cinemas (name, address, price, tags) 
            VALUES (?, ?, ?, ?)''',
            (name, address, price, tags_json)
        )
        conn.commit()
        cinema_id = cursor.lastrowid
        conn.close()
        return cinema_id
    except Exception as e:
        conn.close()
        raise e

def get_all_cinemas():
    """获取所有影院"""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM cinemas ORDER BY created_at DESC')
    cinemas = cursor.fetchall()
    conn.close()
    
    # 转换为字典列表
    cinema_list = []
    for cinema in cinemas:
        # 解析JSON标签
        tags = json.loads(cinema['tags']) if cinema['tags'] else []
        
        cinema_list.append({
            'id': cinema['id'],
            'name': cinema['name'],
            'address': cinema['address'],
            'price': cinema['price'],
            'tags': tags,
            'created_at': cinema['created_at'],
            'updated_at': cinema['updated_at']
        })
    
    return cinema_list

def get_cinema_by_id(cinema_id):
    """根据ID获取影院"""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM cinemas WHERE id = ?', (cinema_id,))
    cinema = cursor.fetchone()
    conn.close()
    
    if cinema:
        # 解析JSON标签
        tags = json.loads(cinema['tags']) if cinema['tags'] else []
        
        return {
            'id': cinema['id'],
            'name': cinema['name'],
            'address': cinema['address'],
            'price': cinema['price'],
            'tags': tags,
            'created_at': cinema['created_at'],
            'updated_at': cinema['updated_at']
        }
    return None

def update_cinema(cinema_id, name=None, address=None, price=None, tags=None):
    """更新影院信息"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # 构建更新字段和值
    update_fields = []
    values = []
    
    if name is not None:
        update_fields.append("name = ?")
        values.append(name)
    
    if address is not None:
        update_fields.append("address = ?")
        values.append(address)
    
    if price is not None:
        update_fields.append("price = ?")
        values.append(price)
    
    if tags is not None:
        tags_json = json.dumps(tags)
        update_fields.append("tags = ?")
        values.append(tags_json)
    
    # 添加更新时间
    update_fields.append("updated_at = ?")
    values.append(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    
    # 添加ID到值列表
    values.append(cinema_id)
    
    if update_fields:
        query = f"UPDATE cinemas SET {', '.join(update_fields)} WHERE id = ?"
        cursor.execute(query, values)
        conn.commit()
        conn.close()
        return True
    else:
        conn.close()
        return False

def delete_cinema(cinema_id):
    """删除影院"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute('DELETE FROM cinemas WHERE id = ?', (cinema_id,))
    conn.commit()
    affected_rows = cursor.rowcount
    conn.close()
    
    return affected_rows > 0

def search_cinemas(keyword=None, min_price=None, max_price=None, tag=None):
    """搜索影院"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    query = "SELECT * FROM cinemas WHERE 1=1"
    params = []
    
    if keyword:
        query += " AND (name LIKE ? OR address LIKE ?)"
        params.extend([f'%{keyword}%', f'%{keyword}%'])
    
    if min_price is not None:
        query += " AND price >= ?"
        params.append(min_price)
    
    if max_price is not None:
        query += " AND price <= ?"
        params.append(max_price)
    
    if tag:
        query += " AND tags LIKE ?"
        params.append(f'%"{tag}"%')
    
    query += " ORDER BY created_at DESC"
    
    cursor.execute(query, params)
    cinemas = cursor.fetchall()
    conn.close()
    
    # 转换为字典列表
    cinema_list = []
    for cinema in cinemas:
        tags = json.loads(cinema['tags']) if cinema['tags'] else []
        
        cinema_list.append({
            'id': cinema['id'],
            'name': cinema['name'],
            'address': cinema['address'],
            'price': cinema['price'],
            'tags': tags,
            'created_at': cinema['created_at'],
            'updated_at': cinema['updated_at']
        })
    
    return cinema_list