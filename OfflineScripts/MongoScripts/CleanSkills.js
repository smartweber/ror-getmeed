conn = new Mongo();
db = conn.getDB("futura");

skills_map = {"android apps": "android", "android development": "android", "android development (java)": "android", "android development toolkit": "android", "android programming": "android", "android(java)": "android", "android.": "android", "android]": "android", "android-adt": "android adt", "android ide": "android ide", "andriod sdk": "android sdk", "android sdk": "android sdk", "android sdk and facebook api.": "android sdk", "angular js": "angularjs", "and apache": "apache", "apache software technologies including: nutch": "apache", "apache web server": "apache", "apache-solr and google maps": "apache solr", "apache-tika": "apache tika", "apache tomcat & google app engine": "apache tomcat", "apache-tomcat": "apache tomcat", "apache-tomcat.": "apache tomcat", "skills: apache tomcat": "apache tomcat", ".net technologes -- asp.net": "asp.net", ".net- asp": "asp.net", "asp .net": "asp.net", "asp. net": "asp.net", "asp.net": "asp.net", "asp.net framework": "asp.net", "[c": "c", "c  programming": "c", "c language": "c", "c programming": "c", "c programming language": "c", "c · unix": "c", "c.": "c", "c]": "c", "language: c": "c", "c - sockets": "c sockets", "c- sockets": "c sockets", "c#": "c#", "c# basics": "c#", "skills: c#": "c#", "c ++": "c++", "c++ (kernel development)": "c++", "c++ (stl)": "c++", "c++ (unix and windows) in ube": "c++", "environment: c++": "c++", "calico.": "calico", "cognito)": "cognito", "core-java": "core java", "css2": "css 2", "css(3)": "css 3", "css.": "css 3", "css3": "css 3", "css3 (animations)": "css 3", "css3.": "css 3", "css3.0": "css 3", "drupal.": "drupal", "ebs)": "ebs", "and eclipse.": "eclipse", "and facebook apis": "facebook api", "and facebook connect api's.": "facebook api", "fedora os.": "fedora os", "technologies: freebsd": "freebsd", "hadoop (mapreduce)": "hadoop", "hadoop(basic)": "hadoop", "hadoop(hbase).": "hadoop", "skills: hbase": "hbase", "html]": "html", "html4": "html 4", "html(5)": "html 5", "html5": "html 5", "interactive data language (idl).": "idl", "ios(basic)": "ios", "j2ee.": "j2ee", "java (j2ee)": "j2ee", "java(j2ee)": "j2ee", "java (j2me)": "j2me", "[java": "java", "[java]": "java", "advance java": "java", "advanced java": "java", "java (android)": "java", "java.": "java", "technologies used: java": "java", "technologies: java": "java", "java and php.": "java, php", "java. spring": "java, spring", "[javascript": "javascript", "and javascript": "javascript", "javascipt": "javascript", "javascirpt": "javascript", "javascrip t": "javascript", "javascript": "javascript", "javascript (jquery)": "javascript", "javascript and json": "javascript", "javascript(jquery)": "javascript", "javascript.": "javascript", "javascripts": "javascript", "javscript": "javascript", "javsscript": "javascript", "jdbc.": "jdbc", "skills:  jdbc": "jdbc", "jquery.": "jquery", "json)": "json", "json.": "json", "json. android": "json, android", "jsonld.": "jsonid", "lamp(apache": "lamp", "lamp.": "lamp", "linq (language integrated query language)": "linq", "and linux": "linux", "linux (ubuntu).": "linux", "linux administration (permissions": "linux", "linux operating system": "linux", "linux shell": "linux", "linux ubuntu": "linux", "linux(ubuntu 12.04)": "linux", "linux(ubuntu)": "linux", "linux.": "linux", "linux/unix": "linux", "linux.javascript": "linux, javascript", "lpsolve.": "lpsolve", "lte - epc": "lte epc", "mallet.": "mallet", "and matlab.": "matlab", "matlab.": "matlab", "and microsoft visio.": "microsoft visio", "ms sql.": "ms sql", "and mysql": "mysql", "technologies used: mysql": "mysql", "java (netbeans)": "netbeans", "skills: objective c": "objective c", "oracle.": "oracle", "perl (scripting)": "perl", "perl scripting": "perl", "#php": "php", "[php": "php", "skills : php": "php", "rds)": "rds", "linux shell scripting": "shell", "sql]": "sql", "sql( oracle)": "sql (oracle)", "sql(oracle)": "sql (oracle)", "and svn": "svn", "svn.": "svn", "unix.": "unix", "xml.": "xml", "xml parser(dom": "xml parser"};
var generate_skills = function(skills_string) {
    var skills = skills_string.split(',');
    if (skills.length === 0) {
        return [];
    }
    return skills_string.split(',').map(function(s){return s.trim().toLowerCase();});
}

var clean_skills = function(skills) {
    var skills
    if (typeof(skills) === "string") {
        skills = generate_skills(skills);
    }
    if (skills.length === 0) {
        return [];
    }
    skills = skills.map(function(s) {
        return (skills_map[s] === undefined ? s : skills_map[s]);
    });
    return skills;
}


db.user_courses.find().forEach(function(course) {
    if (course["skills"] == null) {
        course["skills"] = "";
    }
    new_skills = clean_skills(course["skills"]);
    db.user_courses.update({_id: course["_id"]}, {$set: {skills: new_skills}}, {});
});

db.user_internships.find().forEach(function(intern) {
    if (intern["skills"] == null) {
        intern["skills"] = "";
    }
    new_skills = clean_skills(intern["skills"]);
    db.user_internships.update({_id: intern["_id"]}, {$set: {skills: new_skills}}, {});
});

db.user_works.find().forEach(function(work) {
    if (work["skills"] == null) {
        work["skills"] = "";
    }
    new_skills = clean_skills(work["skills"]);
    db.user_works.update({_id: work["_id"]}, {$set: {skills: new_skills}}, {});
});
