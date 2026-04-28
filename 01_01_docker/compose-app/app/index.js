const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
const PORT = 3000;

// MySQL 연결 설정
const dbConfig = {
  host: process.env.DB_HOST || 'mysql',
  user: process.env.DB_USER || 'appuser',
  password: process.env.DB_PASSWORD || 'apppassword',
  database: process.env.DB_NAME || 'composedb'
};

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 메인 엔드포인트
app.get('/', async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute('SELECT NOW() as current_time');
    await connection.end();
    res.json({
      message: 'Docker Compose 실습에 오신 것을 환영합니다!',
      db_time: rows[0].current_time,
      hostname: require('os').hostname()
    });
  } catch (error) {
    res.status(500).json({
      message: 'DB 연결 실패',
      error: error.message
    });
  }
});

app.listen(PORT, () => {
  console.log(`App server is running on port ${PORT}`);
});
