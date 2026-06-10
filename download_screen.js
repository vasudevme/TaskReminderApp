const https = require('https');
const fs = require('fs');

const url = 'https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sX2Q3MTM1YzE3ZjVlMDRlYmI5YWE3MTc3N2E3MmJjN2VjEgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086';

https.get(url, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    fs.writeFileSync('home.html', data);
    console.log('Downloaded home.html, length:', data.length);
    console.log('Status code:', res.statusCode);
  });
}).on('error', (err) => {
  console.error('Error:', err);
});
