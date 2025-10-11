#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量添加A2词汇
重点类别：通讯科技、娱乐运动、抽象概念、工作学习、社交关系
目标：补充150个A2高频词汇，提升CEFR覆盖率到95%+
"""

import json
from datetime import datetime

# 读取现有词汇
with open('assets/data/sample_words.json', 'r', encoding='utf-8') as f:
    words = json.load(f)

# 找到最大ID
max_id = max([int(w['id']) for w in words])
print(f"当前最大ID: {max_id}")
print(f"当前A2词汇数: {len([w for w in words if w.get('level') == 'A2'])}")

# 新词汇列表
new_words = []
current_id = max_id + 1

# ========== 1. 通讯科技 (35词) ==========
technology = [
    ("computer", "电脑", "computer", "komˈpjuter", ["Lavoro al computer. - 我用电脑工作。", "Ho comprato un nuovo computer. - 我买了一台新电脑。"]),
    ("telefono", "电话", "telephone", "teˈlɛfono", ["Il mio telefono è rotto. - 我的电话坏了。", "Ti chiamo al telefono. - 我给你打电话。"]),
    ("cellulare", "手机", "mobile phone", "tʃelluˈlare", ["Il mio cellulare è nuovo. - 我的手机是新的。", "Uso il cellulare ogni giorno. - 我每天用手机。"]),
    ("smartphone", "智能手机", "smartphone", "ˈsmartfon", ["Ho uno smartphone moderno. - 我有一部现代智能手机。", "Lo smartphone è utile. - 智能手机很有用。"]),
    ("Internet", "互联网", "Internet", "ˈinternet", ["Uso Internet ogni giorno. - 我每天上网。", "Internet è veloce. - 网速快。"]),
    ("rete", "网络", "network", "ˈrete", ["La rete non funziona. - 网络不工作。", "Connetto alla rete Wi-Fi. - 我连接到Wi-Fi网络。"]),
    ("sito", "网站", "website", "ˈsito", ["Visito il sito web. - 我访问网站。", "Questo sito è interessante. - 这个网站很有趣。"]),
    ("email", "电子邮件", "email", "iˈmeil", ["Ti mando un'email. - 我给你发邮件。", "Controllo le email. - 我查看邮件。"]),
    ("messaggio", "消息", "message", "mesˈsaddʒo", ["Ti mando un messaggio. - 我给你发消息。", "Ho ricevuto un messaggio. - 我收到一条消息。"]),
    ("foto", "照片", "photo", "ˈfɔto", ["Faccio una foto. - 我拍一张照片。", "Le foto sono belle. - 照片很漂亮。"]),
    ("video", "视频", "video", "ˈvideo", ["Guardo un video. - 我看视频。", "Il video è interessante. - 视频很有趣。"]),
    ("schermo", "屏幕", "screen", "ˈskermo", ["Lo schermo è grande. - 屏幕很大。", "Lo schermo è rotto. - 屏幕坏了。"]),
    ("tastiera", "键盘", "keyboard", "tasˈtjera", ["La tastiera è comoda. - 键盘很舒服。", "Scrivo con la tastiera. - 我用键盘打字。"]),
    ("mouse", "鼠标", "mouse", "maus", ["Il mouse non funziona. - 鼠标不工作。", "Uso il mouse. - 我用鼠标。"]),
    ("stampante", "打印机", "printer", "stamˈpante", ["La stampante è rotta. - 打印机坏了。", "Stampo con la stampante. - 我用打印机打印。"]),
    ("applicazione", "应用程序", "application", "applikatˈtsjone", ["Scarico un'applicazione. - 我下载一个应用。", "Questa applicazione è utile. - 这个应用很有用。"]),
    ("app", "应用", "app", "app", ["Uso molte app. - 我用很多应用。", "Questa app è gratis. - 这个应用是免费的。"]),
    ("social media", "社交媒体", "social media", "ˈsoutʃal ˈmidja", ["Uso i social media. - 我用社交媒体。", "I social media sono popolari. - 社交媒体很受欢迎。"]),
    ("account", "账户", "account", "akˈkaunt", ["Creo un account. - 我创建一个账户。", "Ho un account. - 我有一个账户。"]),
    ("password", "密码", "password", "ˈpassword", ["La mia password è sicura. - 我的密码很安全。", "Dimentico la password. - 我忘记密码了。"]),
    ("profilo", "个人资料", "profile", "proˈfilo", ["Aggiorno il mio profilo. - 我更新我的资料。", "Il tuo profilo è interessante. - 你的资料很有趣。"]),
    ("batteria", "电池", "battery", "batteˈria", ["La batteria è scarica. - 电池没电了。", "Carico la batteria. - 我给电池充电。"]),
    ("caricabatterie", "充电器", "charger", "karikabaˈtterje", ["Dove è il caricabatterie? - 充电器在哪里？", "Ho bisogno del caricabatterie. - 我需要充电器。"]),
    ("cavo", "电缆/线", "cable", "ˈkavo", ["Il cavo è lungo. - 线很长。", "Ho bisogno di un cavo. - 我需要一根线。"]),
    ("wifi", "无线网络", "wifi", "ˈwaifai", ["Il wifi non funziona. - Wi-Fi不工作。", "Connetto al wifi. - 我连接Wi-Fi。"]),
    ("connessione", "连接", "connection", "konnesˈsjone", ["La connessione è lenta. - 连接很慢。", "Ho una buona connessione. - 我有一个好的连接。"]),
    ("scaricare", "下载", "download", "skariˈkare", ["Scarico un film. - 我下载一部电影。", "Posso scaricare questa app? - 我可以下载这个应用吗？"]),
    ("caricare", "上传/充电", "upload/charge", "kariˈkare", ["Carico le foto. - 我上传照片。", "Carico il telefono. - 我给手机充电。"]),
    ("aggiornare", "更新", "update", "addʒorˈnare", ["Aggiorno il sistema. - 我更新系统。", "Devo aggiornare l'app. - 我需要更新应用。"]),
    ("cliccare", "点击", "click", "klikˈkare", ["Clicco sul link. - 我点击链接。", "Devi cliccare qui. - 你需要点这里。"]),
    ("digitare", "输入", "type", "digiˈtare", ["Digito la password. - 我输入密码。", "Digita il tuo nome. - 输入你的名字。"]),
    ("salvare", "保存", "save", "salˈvare", ["Salvo il documento. - 我保存文档。", "Non dimenticare di salvare! - 别忘记保存！"]),
    ("cancellare", "删除", "delete", "kantʃelˈlare", ["Cancello il file. - 我删除文件。", "Posso cancellare questo? - 我可以删除这个吗？"]),
    ("condividere", "分享", "share", "kondiˈvidere", ["Condivido la foto. - 我分享照片。", "Vuoi condividere? - 你想分享吗？"]),
    ("tecnologia", "技术", "technology", "teknoloˈdʒia", ["La tecnologia è importante. - 技术很重要。", "Amo la tecnologia. - 我喜欢技术。"]),
]

for italian, chinese, english, pronunciation, examples in technology:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "通讯科技",
        "level": "A2",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# ========== 2. 娱乐运动 (30词) ==========
entertainment = [
    ("musica", "音乐", "music", "ˈmuzika", ["Ascolto la musica. - 我听音乐。", "La musica è bella. - 音乐很美。"]),
    ("canzone", "歌曲", "song", "kanˈtsone", ["Questa canzone è bella. - 这首歌很好听。", "Canto una canzone. - 我唱一首歌。"]),
    ("cantare", "唱歌", "sing", "kanˈtare", ["Mi piace cantare. - 我喜欢唱歌。", "Lui canta bene. - 他唱得好。"]),
    ("suonare", "演奏", "play (instrument)", "swoˈnare", ["Suono la chitarra. - 我弹吉他。", "Lei suona il pianoforte. - 她弹钢琴。"]),
    ("chitarra", "吉他", "guitar", "kiˈtarra", ["Ho una chitarra. - 我有一把吉他。", "Suono la chitarra. - 我弹吉他。"]),
    ("pianoforte", "钢琴", "piano", "pjanoˈfɔrte", ["Il pianoforte è grande. - 钢琴很大。", "Imparo il pianoforte. - 我学钢琴。"]),
    ("concerto", "音乐会", "concert", "konˈtʃɛrto", ["Vado al concerto. - 我去音乐会。", "Il concerto è stasera. - 音乐会是今晚。"]),
    ("cinema", "电影院", "cinema", "ˈtʃinema", ["Andiamo al cinema. - 我们去电影院。", "Il cinema è vicino. - 电影院很近。"]),
    ("film", "电影", "film", "film", ["Guardo un film. - 我看电影。", "Il film è interessante. - 电影很有趣。"]),
    ("attore", "演员(男)", "actor", "atˈtore", ["Lui è un attore famoso. - 他是著名演员。", "L'attore è bravo. - 演员很棒。"]),
    ("attrice", "演员(女)", "actress", "atˈtritʃe", ["Lei è un'attrice. - 她是演员。", "L'attrice è brava. - 女演员很棒。"]),
    ("teatro", "剧院", "theater", "teˈatro", ["Vado a teatro. - 我去剧院。", "Lo spettacolo è a teatro. - 演出在剧院。"]),
    ("spettacolo", "演出", "show", "spetˈtakolo", ["Lo spettacolo è bello. - 演出很精彩。", "Guardo uno spettacolo. - 我看演出。"]),
    ("ballare", "跳舞", "dance", "balˈlare", ["Mi piace ballare. - 我喜欢跳舞。", "Balliamo insieme! - 我们一起跳舞！"]),
    ("danza", "舞蹈", "dance", "ˈdantsa", ["Studio danza. - 我学舞蹈。", "La danza è arte. - 舞蹈是艺术。"]),
    ("festa", "派对/节日", "party/festival", "ˈfɛsta", ["Vado alla festa. - 我去派对。", "La festa è domani. - 派对是明天。"]),
    ("sport", "运动", "sport", "spɔrt", ["Faccio sport. - 我做运动。", "Lo sport è sano. - 运动很健康。"]),
    ("calcio", "足球", "soccer", "ˈkaltʃo", ["Gioco a calcio. - 我踢足球。", "Il calcio è popolare. - 足球很受欢迎。"]),
    ("pallacanestro", "篮球", "basketball", "pallakaˈnestro", ["Gioco a pallacanestro. - 我打篮球。", "La pallacanestro è divertente. - 篮球很有趣。"]),
    ("nuotare", "游泳", "swim", "nwoˈtare", ["Mi piace nuotare. - 我喜欢游泳。", "Nuoto in piscina. - 我在游泳池游泳。"]),
    ("piscina", "游泳池", "swimming pool", "piʃˈʃina", ["Vado in piscina. - 我去游泳池。", "La piscina è grande. - 游泳池很大。"]),
    ("correre", "跑步", "run", "ˈkorrere", ["Mi piace correre. - 我喜欢跑步。", "Corro ogni mattina. - 我每天早上跑步。"]),
    ("bicicletta", "自行车", "bicycle", "bitʃiˈkletta", ["Vado in bicicletta. - 我骑自行车。", "La bicicletta è rossa. - 自行车是红色的。"]),
    ("squadra", "队伍", "team", "ˈskwadra", ["La mia squadra vince. - 我的队赢了。", "Gioco in una squadra. - 我在一个队里。"]),
    ("partita", "比赛", "match", "parˈtita", ["Guardo la partita. - 我看比赛。", "La partita è domani. - 比赛是明天。"]),
    ("vincere", "赢", "win", "ˈvintʃere", ["La mia squadra vince. - 我的队赢了。", "Voglio vincere! - 我想赢！"]),
    ("perdere", "输", "lose", "ˈpɛrdere", ["Non voglio perdere. - 我不想输。", "Abbiamo perso la partita. - 我们输了比赛。"]),
    ("hobby", "爱好", "hobby", "ˈɔbbi", ["Il mio hobby è leggere. - 我的爱好是阅读。", "Quali sono i tuoi hobby? - 你的爱好是什么？"]),
    ("passatempo", "消遣", "pastime", "passaˈtɛmpo", ["La lettura è il mio passatempo. - 阅读是我的消遣。", "Hai un passatempo? - 你有消遣吗？"]),
    ("divertimento", "娱乐/乐趣", "fun", "divertiˈmento", ["È per divertimento. - 这是为了娱乐。", "Il divertimento è importante. - 娱乐很重要。"]),
]

for italian, chinese, english, pronunciation, examples in entertainment:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "娱乐运动",
        "level": "A2",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# ========== 3. 抽象概念 (30词) ==========
abstract = [
    ("cosa", "事情/东西", "thing", "ˈkɔza", ["Che cosa fai? - 你在做什么？", "È una bella cosa. - 这是件好事。"]),
    ("idea", "想法/主意", "idea", "iˈdɛa", ["Ho un'idea! - 我有一个主意！", "È una buona idea. - 这是个好主意。"]),
    ("problema", "问题", "problem", "proˈblɛma", ["Ho un problema. - 我有一个问题。", "Il problema è difficile. - 问题很难。"]),
    ("soluzione", "解决方案", "solution", "solutˈtsjone", ["Ho trovato la soluzione. - 我找到了解决方案。", "Questa è la soluzione. - 这是解决方案。"]),
    ("motivo", "原因", "reason", "moˈtivo", ["Qual è il motivo? - 原因是什么？", "Non c'è motivo. - 没有原因。"]),
    ("ragione", "理由/理性", "reason", "raˈdʒone", ["Hai ragione. - 你是对的。", "La ragione è semplice. - 理由很简单。"]),
    ("modo", "方式", "way", "ˈmɔdo", ["In questo modo. - 用这种方式。", "C'è un altro modo? - 有另一种方式吗？"]),
    ("maniera", "方式/方法", "manner", "maˈnjera", ["In questa maniera. - 以这种方式。", "È una buona maniera. - 这是一个好方法。"]),
    ("importanza", "重要性", "importance", "importˈtantsa", ["È di grande importanza. - 这很重要。", "L'importanza è chiara. - 重要性很明显。"]),
    ("valore", "价值", "value", "vaˈlore", ["Ha grande valore. - 有很大价值。", "Il valore è alto. - 价值很高。"]),
    ("qualità", "质量", "quality", "kwaliˈta", ["La qualità è buona. - 质量好。", "È di alta qualità. - 是高质量的。"]),
    ("quantità", "数量", "quantity", "kwantiˈta", ["La quantità è grande. - 数量大。", "Dipende dalla quantità. - 取决于数量。"]),
    ("parte", "部分", "part", "ˈparte", ["Una parte del libro. - 书的一部分。", "Faccio parte della squadra. - 我是队伍的一部分。"]),
    ("tutto", "全部", "all", "ˈtutto", ["Tutto va bene. - 一切都好。", "Mangio tutto. - 我全吃了。"]),
    ("niente", "什么都没有", "nothing", "ˈnjɛnte", ["Non c'è niente. - 什么都没有。", "Non voglio niente. - 我什么都不想要。"]),
    ("qualcosa", "某事/某物", "something", "kwalˈkɔza", ["C'è qualcosa? - 有什么吗？", "Voglio qualcosa. - 我想要什么东西。"]),
    ("volta", "次/倍", "time", "ˈvolta", ["Una volta. - 一次。", "Tre volte. - 三次。"]),
    ("momento", "时刻", "moment", "moˈmento", ["Un momento, per favore. - 等一下。", "È il momento giusto. - 这是正确的时刻。"]),
    ("periodo", "时期", "period", "peˈriodo", ["In questo periodo. - 在这个时期。", "Un breve periodo. - 一个短时期。"]),
    ("inizio", "开始", "beginning", "iˈnittsjo", ["All'inizio. - 在开始。", "L'inizio è difficile. - 开始很难。"]),
    ("fine", "结束/末尾", "end", "ˈfine", ["Alla fine. - 最后。", "La fine del film. - 电影的结尾。"]),
    ("differenza", "差异", "difference", "diffeˈrɛntsa", ["C'è una differenza. - 有一个差异。", "Qual è la differenza? - 差异是什么？"]),
    ("somiglianza", "相似", "similarity", "somiʎˈʎantsa", ["C'è somiglianza. - 有相似之处。", "La somiglianza è chiara. - 相似性很明显。"]),
    ("possibilità", "可能性", "possibility", "possibiliˈta", ["C'è una possibilità. - 有一个可能性。", "È una buona possibilità. - 这是个好机会。"]),
    ("necessità", "必要性", "necessity", "netʃessiˈta", ["È una necessità. - 这是必需的。", "La necessità è chiara. - 必要性很明显。"]),
    ("verità", "真相", "truth", "veriˈta", ["Dico la verità. - 我说真话。", "La verità è importante. - 真相很重要。"]),
    ("bugia", "谎言", "lie", "buˈdʒia", ["È una bugia. - 这是谎言。", "Non dire bugie! - 别说谎！"]),
    ("segreto", "秘密", "secret", "seˈɡrɛto", ["È un segreto. - 这是秘密。", "Non dire il segreto! - 别说出秘密！"]),
    ("sorpresa", "惊喜", "surprise", "sorˈpreza", ["È una sorpresa! - 这是一个惊喜！", "La sorpresa è bella. - 惊喜很美好。"]),
    ("fortuna", "运气", "luck", "forˈtuna", ["Buona fortuna! - 祝你好运！", "Ho fortuna. - 我有运气。"]),
]

for italian, chinese, english, pronunciation, examples in abstract:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "抽象概念",
        "level": "A2",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# ========== 4. 工作学习 (30词) ==========
work_study = [
    ("lavoro", "工作", "work", "laˈvoro", ["Il mio lavoro è interessante. - 我的工作很有趣。", "Vado al lavoro. - 我去上班。"]),
    ("lavorare", "工作", "work", "lavoˈrare", ["Lavoro in un ufficio. - 我在办公室工作。", "Lui lavora molto. - 他工作很多。"]),
    ("ufficio", "办公室", "office", "ufˈfitʃo", ["Sono in ufficio. - 我在办公室。", "L'ufficio è grande. - 办公室很大。"]),
    ("collega", "同事", "colleague", "kolˈlɛɡa", ["Il mio collega è simpatico. - 我的同事很友好。", "Parlo con i colleghi. - 我和同事说话。"]),
    ("capo", "老板", "boss", "ˈkapo", ["Il capo è severo. - 老板很严格。", "Parlo con il capo. - 我和老板说话。"]),
    ("riunione", "会议", "meeting", "riunˈjone", ["Ho una riunione. - 我有一个会议。", "La riunione è alle 10. - 会议在10点。"]),
    ("progetto", "项目", "project", "proˈdʒɛtto", ["Lavoro su un progetto. - 我在做一个项目。", "Il progetto è importante. - 项目很重要。"]),
    ("compito", "任务/作业", "task", "ˈkɔmpito", ["Ho un compito da fare. - 我有任务要做。", "Il compito è difficile. - 任务很难。"]),
    ("stipendio", "工资", "salary", "stiˈpɛndjo", ["Il mio stipendio è buono. - 我的工资不错。", "Ricevo lo stipendio. - 我收到工资。"]),
    ("contratto", "合同", "contract", "konˈtratto", ["Firmo il contratto. - 我签合同。", "Il contratto è importante. - 合同很重要。"]),
    ("professione", "职业", "profession", "professˈsjone", ["Qual è la tua professione? - 你的职业是什么？", "È una buona professione. - 这是一个好职业。"]),
    ("carriera", "职业生涯", "career", "karˈrjɛra", ["La mia carriera è importante. - 我的职业生涯很重要。", "Faccio carriera. - 我在发展职业。"]),
    ("esperienza", "经验", "experience", "esperˈjɛntsa", ["Ho molta esperienza. - 我有很多经验。", "L'esperienza è utile. - 经验很有用。"]),
    ("curriculum", "简历", "resume", "kurˈrikulum", ["Mando il curriculum. - 我发送简历。", "Il mio curriculum è aggiornato. - 我的简历是最新的。"]),
    ("colloquio", "面试", "interview", "kolˈlɔkwjo", ["Ho un colloquio domani. - 我明天有面试。", "Il colloquio è andato bene. - 面试进行得很好。"]),
    ("studio", "学习/书房", "study", "ˈstudjo", ["Studio l'italiano. - 我学意大利语。", "Il mio studio è piccolo. - 我的书房很小。"]),
    ("studiare", "学习", "study", "stuˈdjare", ["Studio ogni giorno. - 我每天学习。", "Devo studiare di più. - 我需要学习更多。"]),
    ("scuola", "学校", "school", "ˈskwɔla", ["Vado a scuola. - 我去学校。", "La scuola è vicina. - 学校很近。"]),
    ("università", "大学", "university", "universiˈta", ["Studio all'università. - 我在大学学习。", "L'università è grande. - 大学很大。"]),
    ("corso", "课程", "course", "ˈkorso", ["Seguo un corso. - 我上一门课。", "Il corso è interessante. - 课程很有趣。"]),
    ("lezione", "课", "lesson", "letˈtsjone", ["Ho una lezione di italiano. - 我有一节意大利语课。", "La lezione è alle 9. - 课在9点。"]),
    ("insegnante", "教师", "teacher", "inseɲˈɲante", ["Il mio insegnante è bravo. - 我的老师很好。", "L'insegnante spiega bene. - 老师解释得好。"]),
    ("professore", "教授/老师", "professor", "professˈsore", ["Il professore è esperto. - 教授很专业。", "Parlo con il professore. - 我和教授说话。"]),
    ("studente", "学生", "student", "stuˈdɛnte", ["Sono uno studente. - 我是学生。", "Gli studenti studiano. - 学生们学习。"]),
    ("esame", "考试", "exam", "eˈzame", ["Ho un esame domani. - 我明天有考试。", "L'esame è difficile. - 考试很难。"]),
    ("voto", "成绩", "grade", "ˈvɔto", ["Ho preso un buon voto. - 我得了好成绩。", "Il voto è alto. - 成绩很高。"]),
    ("diploma", "文凭", "diploma", "diˈplɔma", ["Ho ottenuto il diploma. - 我获得了文凭。", "Il diploma è importante. - 文凭很重要。"]),
    ("laurea", "学位", "degree", "laˈurea", ["Ho la laurea. - 我有学位。", "Prendo la laurea. - 我获得学位。"]),
    ("biblioteca", "图书馆", "library", "bibliˈotɛka", ["Studio in biblioteca. - 我在图书馆学习。", "La biblioteca è grande. - 图书馆很大。"]),
    ("ricerca", "研究", "research", "riˈtʃɛrka", ["Faccio una ricerca. - 我做研究。", "La ricerca è interessante. - 研究很有趣。"]),
]

for italian, chinese, english, pronunciation, examples in work_study:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "工作学习",
        "level": "A2",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# ========== 5. 社交关系 (25词) ==========
social = [
    ("amicizia", "友谊", "friendship", "amiˈtʃitsja", ["L'amicizia è importante. - 友谊很重要。", "Abbiamo una bella amicizia. - 我们有美好的友谊。"]),
    ("relazione", "关系", "relationship", "relatˈtsjone", ["Ho una buona relazione con lui. - 我和他关系很好。", "La relazione è complicata. - 关系很复杂。"]),
    ("rapporto", "关系", "relationship", "rapˈpɔrto", ["Il rapporto è forte. - 关系很牢固。", "Abbiamo un buon rapporto. - 我们关系很好。"]),
    ("vicino", "邻居", "neighbor", "viˈtʃino", ["Il mio vicino è gentile. - 我的邻居很友好。", "Saluto i vicini. - 我向邻居打招呼。"]),
    ("conoscente", "熟人", "acquaintance", "konoʃˈʃɛnte", ["È solo un conoscente. - 他只是个熟人。", "Ho molti conoscenti. - 我有很多熟人。"]),
    ("incontro", "会面/相遇", "meeting", "inˈkontro", ["Ho un incontro con lei. - 我和她有个会面。", "L'incontro è alle 3. - 会面在3点。"]),
    ("incontrare", "遇见", "meet", "inkontˈrare", ["Incontro un amico. - 我遇见一个朋友。", "Ci incontriamo domani. - 我们明天见面。"]),
    ("appuntamento", "约会", "appointment", "appuntaˈmento", ["Ho un appuntamento. - 我有个约会。", "L'appuntamento è alle 7. - 约会在7点。"]),
    ("invito", "邀请", "invitation", "inˈvito", ["Ricevo un invito. - 我收到邀请。", "Grazie per l'invito! - 谢谢邀请！"]),
    ("invitare", "邀请", "invite", "inviˈtare", ["Ti invito a cena. - 我邀请你吃晚饭。", "Invito gli amici. - 我邀请朋友们。"]),
    ("ospite", "客人", "guest", "ˈɔspite", ["Aspetto gli ospiti. - 我等客人。", "Sei mio ospite. - 你是我的客人。"]),
    ("visitare", "拜访/参观", "visit", "viziˈtare", ["Visito un amico. - 我拜访朋友。", "Visitiamo il museo. - 我们参观博物馆。"]),
    ("visita", "拜访/参观", "visit", "ˈvizita", ["Faccio una visita. - 我去拜访。", "La visita è breve. - 拜访很短。"]),
    ("salutare", "打招呼", "greet", "saluˈtare", ["Saluto gli amici. - 我向朋友打招呼。", "Saluta tua madre! - 向你妈妈问好！"]),
    ("saluto", "问候", "greeting", "saˈluto", ["Mando i miei saluti. - 我送上问候。", "Un saluto cordiale. - 诚挚的问候。"]),
    ("presentare", "介绍", "introduce", "prezenˈtare", ["Ti presento mia sorella. - 我给你介绍我妹妹。", "Mi presento: sono Marco. - 我自我介绍：我是马可。"]),
    ("presentazione", "介绍/演示", "presentation", "prezentatˈtsjone", ["Faccio una presentazione. - 我做介绍。", "La presentazione è lunga. - 演示很长。"]),
    ("compagnia", "陪伴/公司", "company", "kompaɲˈɲia", ["Mi piace la tua compagnia. - 我喜欢你的陪伴。", "Lavoro per una compagnia. - 我为一家公司工作。"]),
    ("gruppo", "小组", "group", "ˈɡruppo", ["Sono nel gruppo. - 我在小组里。", "Il gruppo è grande. - 小组很大。"]),
    ("comunità", "社区", "community", "komuniˈta", ["La comunità è importante. - 社区很重要。", "Faccio parte della comunità. - 我是社区的一部分。"]),
    ("società", "社会/公司", "society", "sotʃeˈta", ["Viviamo in società. - 我们生活在社会中。", "La società cambia. - 社会在变化。"]),
    ("pubblico", "公众/公共的", "public", "ˈpubbliko", ["È un luogo pubblico. - 这是公共场所。", "Il pubblico applaude. - 观众鼓掌。"]),
    ("privato", "私人的", "private", "priˈvato", ["È privato. - 这是私人的。", "Ho un incontro privato. - 我有私人会面。"]),
    ("rispetto", "尊重", "respect", "risˈpetto", ["Ho rispetto per te. - 我尊重你。", "Il rispetto è importante. - 尊重很重要。"]),
    ("educazione", "教育/礼貌", "education", "edukatˈtsjone", ["L'educazione è importante. - 教育很重要。", "Ha molta educazione. - 他很有礼貌。"]),
]

for italian, chinese, english, pronunciation, examples in social:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "社交关系",
        "level": "A2",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# 添加新词汇到列表
words.extend(new_words)

# 写回文件
with open('assets/data/sample_words.json', 'w', encoding='utf-8') as f:
    json.dump(words, f, ensure_ascii=False, indent=2)

print(f"\n✅ 成功添加 {len(new_words)} 个A2词汇!")
print(f"新的总词汇数: {len(words)}")
print(f"新的A2词汇数: {len([w for w in words if w.get('level') == 'A2'])}")
print(f"\n添加的类别统计:")
print(f"  - 通讯科技: 35词")
print(f"  - 娱乐运动: 30词")
print(f"  - 抽象概念: 30词")
print(f"  - 工作学习: 30词")
print(f"  - 社交关系: 25词")
print(f"  总计: 150词")

# 计算A2覆盖率
a2_count = len([w for w in words if w.get('level') == 'A2'])
coverage_low = (a2_count / 1200) * 100
coverage_high = (a2_count / 1000) * 100
print(f"\n📊 CEFR A2覆盖率:")
print(f"  - 标准范围: 1000-1200词")
print(f"  - 当前A2词汇: {a2_count}词")
print(f"  - 覆盖率: {coverage_low:.1f}%-{coverage_high:.1f}%")
