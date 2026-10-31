const fs = require('fs');
const path = require('path');

const skillsDir = path.join(__dirname, 'skills');
const outputFile = path.join(skillsDir, 'index.json');

const skills = [];

// อ่านโฟลเดอร์ย่อยใน skills/
const folders = fs.readdirSync(skillsDir, { withFileTypes: true })
  .filter(dirent => dirent.isDirectory())
  .map(dirent => dirent.name);

folders.forEach(folder => {
  const skillMdPath = path.join(skillsDir, folder, 'SKILL.md');
  let description = `Skill for ${folder}`;
  
  // อ่าน description จาก SKILL.md ถ้ามี
  if (fs.existsSync(skillMdPath)) {
    const content = fs.readFileSync(skillMdPath, 'utf8');
    const descMatch = content.match(/description:\s*(.+)/i);
    if (descMatch) {
      description = descMatch[1].trim();
    }
  }

  skills.push({
    name: folder,
    description: description,
    path: `skills/${folder}`
  });
});

const indexData = {
  "$schema": "https://raw.githubusercontent.com/jame581/GodotPrompter/master/skills/schema.json",
  "skills": skills
};

fs.writeFileSync(outputFile, JSON.stringify(indexData, null, 2));
console.log('Successfully generated skills/index.json!');