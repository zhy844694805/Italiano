#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量添加阅读文章
目标：从10篇增加到20篇（A1: 4→7篇, A2: 6→13篇）
重点类别：实用文本、新闻、社交、广告、通知等
"""

import json
from datetime import datetime

# 读取现有文章
with open('assets/data/reading_passages.json', 'r', encoding='utf-8') as f:
    passages = json.load(f)

print(f"当前文章数: {len(passages)}")
print(f"当前A1: {len([p for p in passages if p.get('level') == 'A1'])}篇")
print(f"当前A2: {len([p for p in passages if p.get('level') == 'A2'])}篇")

# 新文章列表
new_passages = []

# ========== A1级别文章 (3篇) ==========

# A1-1: 超市广告
new_passages.append({
    "id": "reading_011",
    "title": "Offerte del supermercato",
    "titleChinese": "超市促销",
    "level": "A1",
    "category": "实用文本",
    "content": """SUPERMERCATO COOP - OFFERTE DELLA SETTIMANA

Frutta e Verdura:
• Mele: 1,50€ al kg
• Pomodori: 2,00€ al kg
• Insalata: 0,80€ al pezzo

Latticini:
• Latte (1 litro): 0,99€
• Formaggio: 8,50€ al kg
• Yogurt (confezione da 4): 2,30€

Carne e Pesce:
• Pollo: 6,90€ al kg
• Pesce fresco: 12,00€ al kg

ORARI: Lunedì-Sabato 8:00-20:00, Domenica 9:00-13:00

Offerte valide dal 10 al 16 gennaio.""",
    "wordCount": 78,
    "estimatedMinutes": 2,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "苹果多少钱一公斤？",
            "questionItalian": "Quanto costano le mele al kg?",
            "options": ["0,80€", "1,50€", "2,00€", "2,30€"],
            "answer": "1,50€",
            "explanation": "广告中写着：Mele: 1,50€ al kg"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "星期天超市什么时候开门？",
            "questionItalian": "A che ora apre il supermercato la domenica?",
            "options": ["8:00", "9:00", "13:00", "20:00"],
            "answer": "9:00",
            "explanation": "营业时间显示：Domenica 9:00-13:00"
        },
        {
            "id": "q3",
            "type": "choice",
            "question": "一盒酸奶（4个装）多少钱？",
            "questionItalian": "Quanto costa una confezione di yogurt?",
            "options": ["0,99€", "2,00€", "2,30€", "8,50€"],
            "answer": "2,30€",
            "explanation": "广告中：Yogurt (confezione da 4): 2,30€"
        },
        {
            "id": "q4",
            "type": "true_false",
            "question": "促销活动持续一周。",
            "questionItalian": "Le offerte durano una settimana.",
            "options": ["真", "假"],
            "answer": "真",
            "explanation": "文末写着：Offerte valide dal 10 al 16 gennaio（促销有效期1月10-16日，共7天）"
        },
        {
            "id": "q5",
            "type": "choice",
            "question": "什么东西最贵？",
            "questionItalian": "Quale prodotto costa di più?",
            "options": ["鸡肉", "新鲜鱼", "奶酪", "西红柿"],
            "answer": "新鲜鱼",
            "explanation": "新鲜鱼12,00€/kg是价格最高的商品"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# A1-2: 电影院海报
new_passages.append({
    "id": "reading_012",
    "title": "Al cinema",
    "titleChinese": "电影院海报",
    "level": "A1",
    "category": "实用文本",
    "content": """CINEMA ROMA - PROGRAMMA DEL WEEKEND

SABATO 13 GENNAIO
Sala 1: "La Dolce Vita" (Film classico italiano)
Orari: 15:00 - 18:30 - 21:00

Sala 2: "Avventura a Roma" (Commedia)
Orari: 16:00 - 19:30

DOMENICA 14 GENNAIO
Sala 1: "Il Grande Blu" (Documentario)
Orari: 10:00 - 14:00 - 17:00

Sala 2: "Amore a Firenze" (Film romantico)
Orari: 15:30 - 18:00 - 20:30

PREZZI:
• Intero: 10€
• Ridotto (studenti/anziani): 7€
• Bambini sotto 12 anni: 5€

Info: www.cinemaroma.it - Tel. 06-1234567""",
    "wordCount": 96,
    "estimatedMinutes": 2,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "星期六晚上9点放映什么电影？",
            "questionItalian": "Quale film c'è sabato alle 21:00?",
            "options": ["Il Grande Blu", "La Dolce Vita", "Amore a Firenze", "Avventura a Roma"],
            "answer": "La Dolce Vita",
            "explanation": "星期六第一厅21:00场次是《甜蜜生活》"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "学生票多少钱？",
            "questionItalian": "Quanto costa il biglietto ridotto?",
            "options": ["5€", "7€", "10€", "12€"],
            "answer": "7€",
            "explanation": "价格表显示：Ridotto (studenti/anziani): 7€"
        },
        {
            "id": "q3",
            "type": "true_false",
            "question": "星期天有纪录片放映。",
            "questionItalian": "Domenica c'è un documentario.",
            "options": ["真", "假"],
            "answer": "真",
            "explanation": "星期天第一厅放映：Il Grande Blu (Documentario)"
        },
        {
            "id": "q4",
            "type": "choice",
            "question": "《爱在佛罗伦萨》是什么类型的电影？",
            "questionItalian": "Che tipo di film è 'Amore a Firenze'?",
            "options": ["喜剧", "纪录片", "浪漫片", "经典片"],
            "answer": "浪漫片",
            "explanation": "海报标注：Amore a Firenze (Film romantico)"
        },
        {
            "id": "q5",
            "type": "choice",
            "question": "10岁的孩子票价是多少？",
            "questionItalian": "Quanto paga un bambino di 10 anni?",
            "options": ["5€", "7€", "10€", "免费"],
            "answer": "5€",
            "explanation": "价格表：Bambini sotto 12 anni: 5€（12岁以下儿童5欧）"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# A1-3: 公寓出租广告
new_passages.append({
    "id": "reading_013",
    "title": "Annuncio: Appartamento in affitto",
    "titleChinese": "出租公寓广告",
    "level": "A1",
    "category": "实用文本",
    "content": """AFFITTASI APPARTAMENTO - CENTRO MILANO

Appartamento luminoso e moderno, 3 camere da letto, 2 bagni, cucina, soggiorno con balcone.

Caratteristiche:
• Piano: 3° piano con ascensore
• Superficie: 85 mq
• Arredato: Sì (mobili nuovi)
• Riscaldamento: Autonomo
• Aria condizionata: Sì
• Parcheggio: 1 posto auto

Posizione: Vicino alla metro (5 minuti a piedi), supermercato, farmacia, scuole.

Disponibile da: 1° febbraio
Affitto mensile: 1.200€ (spese condominiali incluse)

Contatto: Maria Rossi
Tel: 02-9876543
Email: maria.rossi@email.it

Solo referenze serie!""",
    "wordCount": 89,
    "estimatedMinutes": 2,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "公寓有几个卧室？",
            "questionItalian": "Quante camere da letto ha l'appartamento?",
            "options": ["1", "2", "3", "4"],
            "answer": "3",
            "explanation": "广告开头说：3 camere da letto"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "每月租金是多少？",
            "questionItalian": "Quanto costa l'affitto al mese?",
            "options": ["850€", "1.000€", "1.200€", "1.500€"],
            "answer": "1.200€",
            "explanation": "租金部分：Affitto mensile: 1.200€"
        },
        {
            "id": "q3",
            "type": "true_false",
            "question": "公寓有家具。",
            "questionItalian": "L'appartamento è arredato.",
            "options": ["真", "假"],
            "answer": "真",
            "explanation": "特征中写着：Arredato: Sì (mobili nuovi)"
        },
        {
            "id": "q4",
            "type": "choice",
            "question": "公寓在几楼？",
            "questionItalian": "A che piano è l'appartamento?",
            "options": ["1楼", "2楼", "3楼", "5楼"],
            "answer": "3楼",
            "explanation": "特征：Piano: 3° piano con ascensore"
        },
        {
            "id": "q5",
            "type": "true_false",
            "question": "地铁站离公寓很近。",
            "questionItalian": "La metro è vicina all'appartamento.",
            "options": ["真", "假"],
            "answer": "真",
            "explanation": "位置说明：Vicino alla metro (5 minuti a piedi)"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# ========== A2级别文章 (7篇) ==========

# A2-1: 简单新闻 - 天气预报
new_passages.append({
    "id": "reading_014",
    "title": "Previsioni meteo per il weekend",
    "titleChinese": "周末天气预报",
    "level": "A2",
    "category": "实用文本",
    "content": """METEO ITALIA - PREVISIONI 13-14 GENNAIO

SABATO 13 GENNAIO
Nord Italia: Cielo sereno al mattino, possibili nuvole nel pomeriggio. Temperature: minima 2°C, massima 12°C. Vento debole da nord-est.

Centro Italia: Bel tempo per tutta la giornata. Temperature: minima 5°C, massima 15°C. Mare calmo.

Sud Italia e Isole: Parzialmente nuvoloso con possibili piogge nel pomeriggio in Sicilia. Temperature: minima 8°C, massima 16°C.

DOMENICA 14 GENNAIO
Nord: Cielo coperto con piogge leggere dalla sera. Temperature in calo. Massima 10°C.

Centro: Nuvole in aumento, ma senza piogge. Temperature stabili.

Sud: Miglioramento generale, ritorno del sole. Temperature in leggero aumento.

Consigli: Portate l'ombrello nel Nord e in Sicilia! Al Centro e Sud Italia è un buon weekend per passeggiate all'aria aperta.""",
    "wordCount": 134,
    "estimatedMinutes": 3,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "星期六意大利北部的最高温度是多少？",
            "questionItalian": "Qual è la temperatura massima al Nord sabato?",
            "options": ["10°C", "12°C", "15°C", "16°C"],
            "answer": "12°C",
            "explanation": "北部天气：Temperature: minima 2°C, massima 12°C"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "星期六哪里可能下雨？",
            "questionItalian": "Dove può piovere sabato?",
            "options": ["北部", "中部", "西西里", "全国"],
            "answer": "西西里",
            "explanation": "南部天气：possibili piogge nel pomeriggio in Sicilia"
        },
        {
            "id": "q3",
            "type": "true_false",
            "question": "星期天意大利北部会下雨。",
            "questionItalian": "Domenica piove al Nord Italia.",
            "options": ["真", "假"],
            "answer": "真",
            "explanation": "星期天北部：Cielo coperto con piogge leggere dalla sera"
        },
        {
            "id": "q4",
            "type": "choice",
            "question": "哪个地区星期六有最高温度？",
            "questionItalian": "Quale zona ha la temperatura più alta sabato?",
            "options": ["北部", "中部", "南部", "都一样"],
            "answer": "南部",
            "explanation": "南部最高温16°C，高于北部12°C和中部15°C"
        },
        {
            "id": "q5",
            "type": "choice",
            "question": "天气预报建议什么？",
            "questionItalian": "Cosa consigliano le previsioni?",
            "options": ["待在家", "带雨伞去北部和西西里", "去海滩", "待在室内"],
            "answer": "带雨伞去北部和西西里",
            "explanation": "建议：Portate l'ombrello nel Nord e in Sicilia!"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# A2-2: 社交媒体帖子
new_passages.append({
    "id": "reading_015",
    "title": "Post sui social media",
    "titleChinese": "社交媒体帖子",
    "level": "A2",
    "category": "实用文本",
    "content": """📱 INSTAGRAM POST - @sofia_travels

📍 Venezia, Italia
⏰ Pubblicato 2 ore fa

Buongiorno a tutti! 🌞

Sono finalmente arrivata a Venezia dopo un viaggio in treno di 3 ore da Milano. Questa città è davvero magica! Stamattina ho visitato Piazza San Marco e la Basilica - sono rimasta senza parole per la loro bellezza. 😍

Ora sono seduta in un caffè vicino al Canal Grande, sto bevendo un caffè e mangiando un delizioso tiramisù. L'atmosfera qui è incredibile! Ci sono gondole che passano continuamente e la gente sembra molto felice.

Nel pomeriggio voglio fare un giro in gondola e visitare il Ponte di Rialto. Stasera ho prenotato un ristorante tipico dove proverò i cicchetti veneziani.

Domani parto per Firenze. Mi dispiace lasciare Venezia così presto, ma la mia avventura italiana continua! 🇮🇹✨

Chi di voi è già stato a Venezia? Consigliatemi altri posti da visitare!

❤️ 1,234 Mi piace
💬 87 Commenti
🔄 45 Condivisioni""",
    "wordCount": 162,
    "estimatedMinutes": 3,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "Sofia是怎么到威尼斯的？",
            "questionItalian": "Come è arrivata Sofia a Venezia?",
            "options": ["飞机", "火车", "汽车", "船"],
            "answer": "火车",
            "explanation": "文中说：dopo un viaggio in treno di 3 ore da Milano"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "Sofia上午去了哪里？",
            "questionItalian": "Dove è andata Sofia stamattina?",
            "options": ["里亚托桥", "运河", "圣马可广场", "餐厅"],
            "answer": "圣马可广场",
            "explanation": "文中：Stamattina ho visitato Piazza San Marco e la Basilica"
        },
        {
            "id": "q3",
            "type": "choice",
            "question": "Sofia下午想做什么？",
            "questionItalian": "Cosa vuole fare Sofia nel pomeriggio?",
            "options": ["睡觉", "坐贡多拉和参观里亚托桥", "回米兰", "去佛罗伦萨"],
            "answer": "坐贡多拉和参观里亚托桥",
            "explanation": "下午计划：Nel pomeriggio voglio fare un giro in gondola e visitare il Ponte di Rialto"
        },
        {
            "id": "q4",
            "type": "true_false",
            "question": "Sofia明天会留在威尼斯。",
            "questionItalian": "Sofia resta a Venezia domani.",
            "options": ["真", "假"],
            "answer": "假",
            "explanation": "文中说：Domani parto per Firenze（明天出发去佛罗伦萨）"
        },
        {
            "id": "q5",
            "type": "choice",
            "question": "这个帖子收到了多少个赞？",
            "questionItalian": "Quanti 'Mi piace' ha ricevuto il post?",
            "options": ["45", "87", "1234", "162"],
            "answer": "1234",
            "explanation": "底部统计：❤️ 1,234 Mi piace"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# A2-3: 邮件 - 工作相关
new_passages.append({
    "id": "reading_016",
    "title": "Email di lavoro",
    "titleChinese": "工作邮件",
    "level": "A2",
    "category": "工作学习",
    "content": """Da: marco.bianchi@techitalia.com
A: team@techitalia.com
Data: 15 gennaio 2025, 09:30
Oggetto: Riunione importante - Nuovo progetto

Buongiorno a tutti,

Vi scrivo per informarvi che lunedì prossimo, 22 gennaio, avremo una riunione molto importante alle ore 14:00 in sala conferenze al terzo piano.

Durante la riunione discuteremo il nuovo progetto per il cliente "Milano Fashion Week". Questo progetto è una grande opportunità per la nostra azienda e richiede la collaborazione di tutto il team.

Vi chiedo cortesemente di:
1. Preparare le vostre idee e proposte
2. Portare i report del mese scorso
3. Essere puntuali - la riunione durerà circa 2 ore

Dopo la riunione, faremo un aperitivo insieme per festeggiare i successi dell'ultimo trimestre.

Se avete domande o non potete partecipare, per favore rispondete a questa email entro venerdì.

Grazie per la vostra collaborazione!

Cordiali saluti,
Marco Bianchi
Project Manager
Tech Italia S.r.l.
Tel: +39 02-1234567""",
    "wordCount": 156,
    "estimatedMinutes": 3,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "会议什么时候举行？",
            "questionItalian": "Quando si terrà la riunione?",
            "options": ["1月15日", "1月22日下午2点", "1月22日上午", "周五"],
            "answer": "1月22日下午2点",
            "explanation": "邮件中：lunedì prossimo, 22 gennaio...alle ore 14:00"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "会议在哪里举行？",
            "questionItalian": "Dove si terrà la riunione?",
            "options": ["一楼", "二楼", "三楼会议室", "办公室"],
            "answer": "三楼会议室",
            "explanation": "地点：in sala conferenze al terzo piano"
        },
        {
            "id": "q3",
            "type": "choice",
            "question": "新项目的客户是谁？",
            "questionItalian": "Chi è il cliente del nuovo progetto?",
            "options": ["Tech Italia", "Marco Bianchi", "Milano Fashion Week", "不知道"],
            "answer": "Milano Fashion Week",
            "explanation": "项目介绍：il nuovo progetto per il cliente 'Milano Fashion Week'"
        },
        {
            "id": "q4",
            "type": "true_false",
            "question": "会议后会有庆祝活动。",
            "questionItalian": "Dopo la riunione ci sarà una celebrazione.",
            "options": ["真", "假"],
            "answer": "真",
            "explanation": "邮件说：Dopo la riunione, faremo un aperitivo insieme per festeggiare"
        },
        {
            "id": "q5",
            "type": "choice",
            "question": "如果不能参加会议应该什么时候回复？",
            "questionItalian": "Entro quando bisogna rispondere se non si può partecipare?",
            "options": ["星期一", "立即", "星期五之前", "1月22日"],
            "answer": "星期五之前",
            "explanation": "要求：per favore rispondete a questa email entro venerdì"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# A2-4: 简单新闻 - 文化活动
new_passages.append({
    "id": "reading_017",
    "title": "Festival della musica a Roma",
    "titleChinese": "罗马音乐节",
    "level": "A2",
    "category": "文化",
    "content": """ROMA - Il weekend scorso si è concluso con grande successo il "Festival della Musica Italiana", uno degli eventi musicali più importanti dell'anno. Il festival, che si è svolto dal 10 al 14 gennaio in diversi luoghi della capitale, ha attirato più di 50.000 visitatori.

Durante i cinque giorni di festival, oltre 80 artisti italiani e internazionali si sono esibiti in concerti, spettacoli e performance dal vivo. Il concerto più popolare è stato quello del famoso cantante italiano Marco Mengoni, che ha riempito completamente Piazza del Popolo con 15.000 persone.

"È stata un'esperienza incredibile", ha detto Laura, una studentessa di 22 anni venuta da Milano. "Ho scoperto molti artisti nuovi e l'atmosfera era fantastica. Tornerò sicuramente l'anno prossimo!"

Il festival ha offerto anche workshop gratuiti per musicisti emergenti e lezioni di musica per bambini. Grazie al successo di quest'anno, gli organizzatori hanno già annunciato che il festival tornerà nel 2026 con un programma ancora più ricco.

Il sindaco di Roma ha dichiarato: "Questo festival dimostra che la musica unisce le persone e arricchisce la nostra città. Siamo orgogliosi di ospitare un evento così importante.""",
    "wordCount": 192,
    "estimatedMinutes": 3,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "音乐节持续了多久？",
            "questionItalian": "Quanto è durato il festival?",
            "options": ["3天", "5天", "7天", "10天"],
            "answer": "5天",
            "explanation": "文中说：dal 10 al 14 gennaio（1月10-14日，共5天）"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "有多少游客参加了音乐节？",
            "questionItalian": "Quanti visitatori hanno partecipato al festival?",
            "options": ["15.000", "22.000", "50.000", "80.000"],
            "answer": "50.000",
            "explanation": "参观人数：ha attirato più di 50.000 visitatori"
        },
        {
            "id": "q3",
            "type": "choice",
            "question": "谁是最受欢迎的歌手？",
            "questionItalian": "Chi è stato l'artista più popolare?",
            "options": ["Laura", "市长", "Marco Mengoni", "文中未提及"],
            "answer": "Marco Mengoni",
            "explanation": "最受欢迎的演出：Il concerto più popolare è stato quello...Marco Mengoni"
        },
        {
            "id": "q4",
            "type": "true_false",
            "question": "音乐节为新兴音乐家提供了免费研讨会。",
            "questionItalian": "Il festival ha offerto workshop gratuiti per musicisti emergenti.",
            "options": ["真", "假"],
            "answer": "真",
            "explanation": "文中明确说：Il festival ha offerto anche workshop gratuiti per musicisti emergenti"
        },
        {
            "id": "q5",
            "type": "choice",
            "question": "下一届音乐节什么时候举办？",
            "questionItalian": "Quando ci sarà il prossimo festival?",
            "options": ["2025", "2026", "今年", "不知道"],
            "answer": "2026",
            "explanation": "组织者宣布：il festival tornerà nel 2026"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# A2-5: 博客文章 - 健康生活
new_passages.append({
    "id": "reading_018",
    "title": "Consigli per una vita sana",
    "titleChinese": "健康生活建议",
    "level": "A2",
    "category": "日常生活",
    "content": """BLOG SALUTE - 5 Abitudini per vivere meglio

Ciao a tutti! Oggi voglio condividere con voi alcuni consigli semplici ma efficaci per migliorare la vostra salute e il vostro benessere quotidiano.

1. DORMIRE BENE
È fondamentale dormire 7-8 ore ogni notte. Un buon sonno aiuta il corpo a riposarsi e la mente a essere più concentrata. Provate ad andare a letto sempre alla stessa ora e evitate di usare il telefono prima di dormire.

2. FARE MOVIMENTO
Non è necessario andare in palestra ogni giorno! Anche 30 minuti di camminata al giorno fanno la differenza. Potete andare a piedi al lavoro, usare le scale invece dell'ascensore, o fare una passeggiata nel parco.

3. MANGIARE SANO
Includete nella vostra dieta molta frutta, verdura e cereali integrali. Bevete almeno 2 litri d'acqua al giorno e limitate cibi grassi e zuccheri.

4. RIDURRE LO STRESS
Lo stress fa male alla salute! Dedicate del tempo a voi stessi: leggete un libro, ascoltate musica, meditate o praticate yoga. Anche solo 10 minuti al giorno possono aiutare.

5. SOCIALIZZARE
Passare tempo con amici e famiglia è importante per la salute mentale. Le relazioni positive ci rendono più felici e più forti.

Ricordate: piccoli cambiamenti quotidiani portano grandi risultati! Iniziate con una o due abitudini e aggiungete le altre gradualmente.

Qual è la vostra abitudine preferita per stare bene? Scrivetelo nei commenti!""",
    "wordCount": 238,
    "estimatedMinutes": 3,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "文章建议每晚睡多少小时？",
            "questionItalian": "Quante ore di sonno consiglia l'articolo?",
            "options": ["5-6小时", "7-8小时", "8-10小时", "10小时以上"],
            "answer": "7-8小时",
            "explanation": "睡眠建议：È fondamentale dormire 7-8 ore ogni notte"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "文章建议每天运动多久？",
            "questionItalian": "Quanto movimento consiglia l'articolo al giorno?",
            "options": ["10分钟", "20分钟", "30分钟", "1小时"],
            "answer": "30分钟",
            "explanation": "运动建议：Anche 30 minuti di camminata al giorno fanno la differenza"
        },
        {
            "id": "q3",
            "type": "choice",
            "question": "应该每天喝多少水？",
            "questionItalian": "Quanta acqua bisogna bere al giorno?",
            "options": ["1升", "2升", "3升", "文中未提及"],
            "answer": "2升",
            "explanation": "饮水建议：Bevete almeno 2 litri d'acqua al giorno"
        },
        {
            "id": "q4",
            "type": "true_false",
            "question": "文章说必须每天去健身房。",
            "questionItalian": "L'articolo dice che è necessario andare in palestra ogni giorno.",
            "options": ["真", "假"],
            "answer": "假",
            "explanation": "文章明确说：Non è necessario andare in palestra ogni giorno!"
        },
        {
            "id": "q5",
            "type": "choice",
            "question": "文章建议如何减压？",
            "questionItalian": "Come suggerisce l'articolo di ridurre lo stress?",
            "options": ["多工作", "阅读、听音乐、冥想或瑜伽", "多睡觉", "多吃东西"],
            "answer": "阅读、听音乐、冥想或瑜伽",
            "explanation": "减压方法：leggete un libro, ascoltate musica, meditate o praticate yoga"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# A2-6: 产品评论
new_passages.append({
    "id": "reading_019",
    "title": "Recensione: Ristorante 'Da Giuseppe'",
    "titleChinese": "餐厅评论：朱塞佩餐厅",
    "level": "A2",
    "category": "日常生活",
    "content": """⭐⭐⭐⭐⭐ 5/5 stelle

RECENSIONE di Anna M. - Visitato il 12 gennaio 2025

Ho cenato ieri sera al ristorante "Da Giuseppe" con il mio fidanzato per festeggiare il nostro anniversario, e devo dire che è stata un'esperienza fantastica dall'inizio alla fine!

AMBIENTE
Il locale è accogliente e ben arredato, con un'atmosfera romantica grazie alle luci soffuse e alla musica leggera in sottofondo. Abbiamo avuto un tavolo vicino alla finestra con una bella vista sulla piazza.

SERVIZIO
Il personale è stato cordiale, professionale e molto attento. Il nostro cameriere, Luca, ci ha consigliato ottimi piatti e vini. Il servizio è stato veloce nonostante il ristorante fosse pieno.

CIBO
Abbiamo iniziato con un antipasto di bruschette miste - fresche e saporite! Come primo piatto, io ho preso i ravioli al tartufo (divini!) e il mio fidanzato ha scelto le tagliatelle al ragù. Per secondo, abbiamo condiviso una tagliata di manzo che era cotta perfettamente e accompagnata da verdure grigliate.

Il tiramisù del dessert era così buono che ne abbiamo ordinato un secondo!

PREZZO
Il conto finale è stato di 85€ per due persone, incluso vino e dessert. Un po' caro, ma la qualità giustifica assolutamente il prezzo.

CONCLUSIONE
Torneremo sicuramente! Consiglio vivamente questo ristorante a chiunque cerchi autentica cucina italiana in un ambiente piacevole. Ricordatevi di prenotare, perché è sempre molto frequentato!""",
    "wordCount": 242,
    "estimatedMinutes": 3,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "Anna为什么去这家餐厅？",
            "questionItalian": "Perché Anna è andata al ristorante?",
            "options": ["工作晚餐", "庆祝周年纪念", "朋友聚会", "生日派对"],
            "answer": "庆祝周年纪念",
            "explanation": "文中说：per festeggiare il nostro anniversario"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "Anna的男朋友点了什么第一道菜？",
            "questionItalian": "Cosa ha ordinato il fidanzato di Anna come primo?",
            "options": ["松露馄饨", "肉酱面", "意大利面", "烩饭"],
            "answer": "肉酱面",
            "explanation": "男友点的：il mio fidanzato ha scelto le tagliatelle al ragù"
        },
        {
            "id": "q3",
            "type": "choice",
            "question": "总共花了多少钱？",
            "questionItalian": "Quanto hanno speso in totale?",
            "options": ["65€", "75€", "85€", "95€"],
            "answer": "85€",
            "explanation": "账单：Il conto finale è stato di 85€ per due persone"
        },
        {
            "id": "q4",
            "type": "true_false",
            "question": "Anna觉得餐厅太贵了，不值得。",
            "questionItalian": "Anna pensa che il ristorante sia troppo caro e non valga la pena.",
            "options": ["真", "假"],
            "answer": "假",
            "explanation": "Anna说：Un po' caro, ma la qualità giustifica assolutamente il prezzo（有点贵但质量完全值得）"
        },
        {
            "id": "q5",
            "type": "choice",
            "question": "Anna建议做什么？",
            "questionItalian": "Cosa consiglia Anna?",
            "options": ["避免去这家餐厅", "自带食物", "提前预订", "只点甜点"],
            "answer": "提前预订",
            "explanation": "建议：Ricordatevi di prenotare, perché è sempre molto frequentato!"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# A2-7: 旅游攻略
new_passages.append({
    "id": "reading_020",
    "title": "Guida turistica: Un giorno a Firenze",
    "titleChinese": "旅游攻略：佛罗伦萨一日游",
    "level": "A2",
    "category": "旅游",
    "content": """VISITARE FIRENZE IN UN GIORNO - Itinerario consigliato

Firenze, la capitale del Rinascimento, è una città che merita molto più di un giorno, ma se avete tempo limitato, ecco come sfruttare al meglio le vostre 24 ore!

MATTINA (9:00-13:00)
Iniziate la giornata alla Galleria degli Uffizi, uno dei musei più famosi al mondo. Qui potrete ammirare capolavori di Botticelli, Leonardo da Vinci e Michelangelo. Consiglio: prenotate i biglietti online per evitare lunghe code!

Dopo il museo, camminate fino a Piazza della Signoria e ammirate Palazzo Vecchio. La piazza è piena di statue bellissime e artisti di strada.

PRANZO (13:00-14:30)
Fermatevi in una trattoria tipica per assaggiare la bistecca alla fiorentina, il piatto più famoso della città. Accompagnatela con un buon Chianti toscano!

POMERIGGIO (14:30-18:00)
Attraversate il famoso Ponte Vecchio con le sue botteghe di gioiellieri. Dall'altra parte del fiume, salite fino a Piazzale Michelangelo per godere di una vista panoramica mozzafiato su tutta la città. È il posto perfetto per scattare foto!

Scendendo dalla collina, visitate la Basilica di Santa Croce, dove sono sepolti Michelangelo, Galileo e Machiavelli.

SERA (18:00-22:00)
Al tramonto, passeggiate lungo l'Arno e godetevi l'atmosfera magica della città. Per cena, provate un gelato artigianale (Firenze ne produce di ottimi!) e una pizza in una pizzeria locale.

CONSIGLI PRATICI:
• Indossate scarpe comode - camminerete molto!
• Portate acqua: le fontanelle pubbliche sono ovunque
• I negozi chiudono tra le 13:00 e le 15:30
• Il centro storico è piccolo - tutto è raggiungibile a piedi

Buon viaggio! 🇮🇹""",
    "wordCount": 278,
    "estimatedMinutes": 4,
    "questions": [
        {
            "id": "q1",
            "type": "choice",
            "question": "文章建议早上几点开始参观？",
            "questionItalian": "A che ora consiglia di iniziare la visita la mattina?",
            "options": ["8:00", "9:00", "10:00", "11:00"],
            "answer": "9:00",
            "explanation": "早晨行程：MATTINA (9:00-13:00)"
        },
        {
            "id": "q2",
            "type": "choice",
            "question": "佛罗伦萨最著名的菜是什么？",
            "questionItalian": "Qual è il piatto più famoso di Firenze?",
            "options": ["披萨", "意大利面", "佛罗伦萨牛排", "提拉米苏"],
            "answer": "佛罗伦萨牛排",
            "explanation": "午餐推荐：la bistecca alla fiorentina, il piatto più famoso della città"
        },
        {
            "id": "q3",
            "type": "choice",
            "question": "在哪里可以看到城市全景？",
            "questionItalian": "Dove si può vedere una vista panoramica della città?",
            "options": ["乌菲兹美术馆", "老桥", "米开朗基罗广场", "圣十字教堂"],
            "answer": "米开朗基罗广场",
            "explanation": "全景位置：salite fino a Piazzale Michelangelo per godere di una vista panoramica mozzafiato"
        },
        {
            "id": "q4",
            "type": "true_false",
            "question": "米开朗基罗埋葬在圣十字教堂。",
            "questionItalian": "Michelangelo è sepolto nella Basilica di Santa Croce.",
            "options": ["真", "假"],
            "answer": "真",
            "explanation": "文中明确说：dove sono sepolti Michelangelo, Galileo e Machiavelli"
        },
        {
            "id": "q5",
            "type": "choice",
            "question": "文章给出了什么实用建议？",
            "questionItalian": "Quale consiglio pratico dà l'articolo?",
            "options": ["租车", "穿舒适的鞋", "早上5点出发", "带很多钱"],
            "answer": "穿舒适的鞋",
            "explanation": "实用建议：Indossate scarpe comode - camminerete molto!"
        }
    ],
    "createdAt": datetime.now().isoformat() + "Z"
})

# 添加新文章到列表
passages.extend(new_passages)

# 写回文件
with open('assets/data/reading_passages.json', 'w', encoding='utf-8') as f:
    json.dump(passages, f, ensure_ascii=False, indent=2)

print(f"\n✅ 成功添加 {len(new_passages)} 篇阅读文章!")
print(f"新的总文章数: {len(passages)}")
a1_new = len([p for p in passages if p.get('level') == 'A1'])
a2_new = len([p for p in passages if p.get('level') == 'A2'])
print(f"新的A1文章数: {a1_new}")
print(f"新的A2文章数: {a2_new}")

print(f"\n添加的文章类型统计:")
print(f"  A1级别:")
print(f"    - 超市广告 (实用文本)")
print(f"    - 电影院海报 (实用文本)")
print(f"    - 公寓出租广告 (实用文本)")
print(f"\n  A2级别:")
print(f"    - 天气预报 (实用文本)")
print(f"    - 社交媒体帖子 (实用文本)")
print(f"    - 工作邮件 (工作学习)")
print(f"    - 音乐节新闻 (文化)")
print(f"    - 健康生活博客 (日常生活)")
print(f"    - 餐厅评论 (日常生活)")
print(f"    - 佛罗伦萨旅游攻略 (旅游)")

# 统计总字数
total_words = sum([p['wordCount'] for p in passages])
print(f"\n📊 阅读材料统计:")
print(f"  - 总文章数: {len(passages)}篇")
print(f"  - 总字数: {total_words}词")
print(f"  - 总问题数: {len(passages) * 5}题")
print(f"  - 预计总阅读时间: {sum([p['estimatedMinutes'] for p in passages])}分钟")
