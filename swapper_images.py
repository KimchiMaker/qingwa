from database import get_db_connection
import os
import uuid
from werkzeug.utils import secure_filename

def init_swapper_table():
    """初始化swapper图像表"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 检查表是否存在
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='swapper_images'")
        table_exists = cursor.fetchone()
        
        if not table_exists:
            print("创建 swapper_images 表...")
            cursor.execute('''
                CREATE TABLE swapper_images (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    imageURL TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            conn.commit()
            print("swapper_images 表创建成功")
        else:
            print("swapper_images 表已存在")
            
        conn.close()
        return True
    except Exception as e:
        print(f"初始化swapper表失败: {str(e)}")
        return False

def add_swapper_image(image_url):
    """添加swapper图像记录"""
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            'INSERT INTO swapper_images (imageURL) VALUES (?)',
            (image_url,)
        )
        conn.commit()
        image_id = cursor.lastrowid
        conn.close()
        return image_id
    except Exception as e:
        conn.close()
        raise e

def get_all_swapper_images():
    """获取所有swapper图像"""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM swapper_images ORDER BY created_at DESC')
    images = cursor.fetchall()
    conn.close()
    
    # 转换为字典列表
    image_list = []
    for image in images:
        image_list.append({
            'id': image['id'],
            'imageURL': image['imageURL'],
            'created_at': image['created_at']
        })
    
    return image_list

def delete_swapper_image(image_id):
    """删除swapper图像"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # 先获取图片URL以便删除文件
    cursor.execute('SELECT imageURL FROM swapper_images WHERE id = ?', (image_id,))
    image = cursor.fetchone()
    
    if image:
        image_url = image['imageURL']
        # 删除数据库记录
        cursor.execute('DELETE FROM swapper_images WHERE id = ?', (image_id,))
        conn.commit()
        conn.close()
        
        # 删除物理文件
        try:
            if os.path.exists(image_url):
                os.remove(image_url)
        except Exception as e:
            print(f"删除文件失败: {str(e)}")
        
        return True
    else:
        conn.close()
        return False

def get_swapper_image_by_id(image_id):
    """根据ID获取swapper图像"""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM swapper_images WHERE id = ?', (image_id,))
    image = cursor.fetchone()
    conn.close()
    
    if image:
        return {
            'id': image['id'],
            'imageURL': image['imageURL'],
            'created_at': image['created_at']
        }
    return None