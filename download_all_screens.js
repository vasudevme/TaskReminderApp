const https = require('https');
const fs = require('fs');
const path = require('path');

const screens = [
  {
    id: "9221bb6e0cb94a57bb7c70d4bf1e220b",
    title: "Categories",
    url: "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzY4YTcxNDQ0NTNmNDQyYzlhZTZiZjUzYTI2MGE5OTkxEgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086"
  },
  {
    id: "3ec4cb942cd545d18d71ddcc57d6b491",
    title: "Dashboard_CreateTask",
    url: "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzYwMGU2M2IzMGQ5ZTQ4NmFhOTdiOWE1ZWQwOWUxN2E2EgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086"
  },
  {
    id: "62ac794c6c394db1b05c06e9282307ff",
    title: "Analytics_Trends",
    url: "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzE1YzdhMTQ1NGI1ZjQ1MWI4MGY2YTYzZmNjOTI2NDYzEgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086"
  },
  {
    id: "0fa66ef95e4e462ea7388495267a96f9",
    title: "Add_Reminder_TaskDetails",
    url: "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzc0ZjMwNjQ4MjY2YzRlYzFhNDJmZTgzZThmZDU3NDE3EgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086"
  },
  {
    id: "aced372e733243d7b28dee29a9b8e894",
    title: "Focus_Mode",
    url: "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzgyYzM0MDVkMjAxMzQwNWZhNGJhMGQxZGFiM2ZkYTQwEgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086"
  },
  {
    id: "ae691973e3b944c6af0037c3061a7ed5",
    title: "Settings",
    url: "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sX2M2ODIzNTY3MmM5MjQ1NTRiY2EyMTJjNTMzMmRlM2Q3EgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086"
  },
  {
    id: "f14e599e25dc47489a2477a11e9cf33f",
    title: "Calendar_View",
    url: "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzgwMzE1MWI1NjA2OTQzNzU4ZDk1YWIxNzAyYzVjOWQ3EgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086"
  },
  {
    id: "f05069143d2644b4a106d82d6c44a2cb",
    title: "Search_Reminders",
    url: "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sXzkyMDAzMzI1ZjBjZjQyYzViODNiODA1YWU3Y2NmMTU1EgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086"
  },
  {
    id: "def4bbbc8e15413887a1b846bac6fe90",
    title: "Focus_Mode_Home",
    url: "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ7Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpaCiVodG1sX2Q3MTM1YzE3ZjVlMDRlYmI5YWE3MTc3N2E3MmJjN2VjEgsSBxDJufqZswIYAZIBIwoKcHJvamVjdF9pZBIVQhMxNTUwMzczMzc3NzAzNjIxMjE2&filename=&opi=89354086"
  }
];

const outputDir = path.join(__dirname, 'stitch_html_screens');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir);
}

function download(screen, callback) {
  const filePath = path.join(outputDir, `${screen.title}_${screen.id}.html`);
  https.get(screen.url, (res) => {
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    res.on('end', () => {
      fs.writeFileSync(filePath, data);
      console.log(`Downloaded ${screen.title} to ${filePath} (${data.length} bytes)`);
      callback(null);
    });
  }).on('error', (err) => {
    console.error(`Error downloading ${screen.title}:`, err);
    callback(err);
  });
}

function downloadAll(index) {
  if (index >= screens.length) {
    console.log('All downloads completed successfully!');
    return;
  }
  download(screens[index], () => {
    downloadAll(index + 1);
  });
}

downloadAll(0);
