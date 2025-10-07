#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
添加新词汇到sample_words.json
"""
import json

def main():
    # Read existing words
    with open('assets/data/sample_words.json', 'r', encoding='utf-8') as f:
        words = json.load(f)

    print(f"当前词汇数量: {len(words)}")

    # 新词汇数据 (ID 461-600, 共140个)
    new_words_data = [
        # 食物餐饮相关 (ID 461-480)
        ("461", "bottiglia", "瓶子", "bottle", "botˈtiʎʎa", "食物餐饮", "A1", ["Una bottiglia di vino. - 一瓶葡萄酒。", "La bottiglia è vuota. - 瓶子是空的。"]),
        ("462", "dolce", "甜的/甜点", "sweet/dessert", "ˈdoltʃe", "食物餐饮", "A1", ["Mi piace il dolce. - 我喜欢甜食。", "Questo è troppo dolce. - 这太甜了。"]),
        ("463", "salato", "咸的", "salty", "saˈlaːto", "食物餐饮", "A2", ["È troppo salato. - 太咸了。", "Mi piace il cibo salato. - 我喜欢咸的食物。"]),
        ("464", "amaro", "苦的", "bitter", "aˈmaːro", "食物餐饮", "A2", ["Il caffè è amaro. - 咖啡是苦的。", "Ha un sapore amaro. - 它有苦味。"]),
        ("465", "piccante", "辣的", "spicy", "pikˈkante", "食物餐饮", "A2", ["Ti piace il cibo piccante? - 你喜欢辣的食物吗？", "Questo è molto piccante. - 这很辣。"]),
        ("466", "fresco", "新鲜的", "fresh", "ˈfresko", "食物餐饮", "A2", ["Il pesce è fresco. - 鱼很新鲜。", "Fa fresco oggi. - 今天很凉爽。"]),
        ("467", "verdura", "蔬菜", "vegetable", "verˈduːra", "食物餐饮", "A1", ["Mangio molta verdura. - 我吃很多蔬菜。", "La verdura fa bene. - 蔬菜有益健康。"]),
        ("468", "insalata", "沙拉", "salad", "insaˈlaːta", "食物餐饮", "A1", ["Vorrei un'insalata. - 我想要一份沙拉。", "L'insalata è fresca. - 沙拉很新鲜。"]),
        ("469", "minestra", "汤", "soup", "miˈnestra", "食物餐饮", "A2", ["La minestra è calda. - 汤很热。", "Prendo una minestra. - 我要一份汤。"]),
        ("470", "secondo", "主菜", "main dish", "seˈkondo", "食物餐饮", "A2", ["Come secondo prendo il pesce. - 主菜我要鱼。", "Il secondo è pronto. - 主菜准备好了。"]),
        ("471", "contorno", "配菜", "side dish", "konˈtorno", "食物餐饮", "A2", ["Quale contorno vuoi? - 你要什么配菜？", "Vorrei le patate come contorno. - 我想要土豆作为配菜。"]),
        ("472", "olio", "油", "oil", "ˈɔːljo", "食物餐饮", "A1", ["L'olio d'oliva è buono. - 橄榄油很好。", "Aggiungi un po' d'olio. - 加一点油。"]),
        ("473", "aceto", "醋", "vinegar", "aˈtʃeːto", "食物餐饮", "A2", ["Un po' di olio e aceto. - 一点油和醋。", "L'aceto balsamico è tipico. - 香醋是典型的。"]),
        ("474", "sale", "盐", "salt", "ˈsaːle", "食物餐饮", "A1", ["Passa il sale, per favore. - 请递给我盐。", "C'è troppo sale. - 盐太多了。"]),
        ("475", "pepe", "胡椒", "pepper", "ˈpeːpe", "食物餐饮", "A2", ["Mi piace il pepe nero. - 我喜欢黑胡椒。", "Aggiungi del pepe. - 加一些胡椒。"]),
        ("476", "zucchero", "糖", "sugar", "ˈdzukkero", "食物餐饮", "A1", ["Vuoi lo zucchero nel caffè? - 你咖啡要加糖吗？", "Non uso zucchero. - 我不用糖。"]),
        ("477", "burro", "黄油", "butter", "ˈburro", "食物餐饮", "A2", ["Il pane con il burro. - 面包配黄油。", "Il burro è nel frigo. - 黄油在冰箱里。"]),
        ("478", "marmellata", "果酱", "jam", "marmelˈlaːta", "食物餐饮", "A2", ["La marmellata di fragole. - 草莓果酱。", "Spalmo la marmellata sul pane. - 我在面包上涂果酱。"]),
        ("479", "miele", "蜂蜜", "honey", "ˈmjɛːle", "食物餐饮", "A2", ["Il miele è dolce. - 蜂蜜是甜的。", "Aggiungi un cucchiaio di miele. - 加一勺蜂蜜。"]),
        ("480", "uovo", "鸡蛋", "egg", "ˈwɔːvo", "食物餐饮", "A1", ["Vorrei due uova. - 我要两个鸡蛋。", "L'uovo è fresco. - 鸡蛋很新鲜。"]),

        # 通讯科技 (ID 481-490)
        ("481", "numero", "号码", "number", "ˈnuːmero", "日常用语", "A1", ["Qual è il tuo numero di telefono? - 你的电话号码是多少？", "Il numero della casa. - 房屋号码。"]),
        ("482", "indirizzo", "地址", "address", "indiˈrittso", "日常用语", "A1", ["Qual è il tuo indirizzo? - 你的地址是什么？", "Scrivi l'indirizzo qui. - 在这里写地址。"]),
        ("483", "telefono", "电话", "telephone", "teˈlɛːfono", "日常用语", "A1", ["Il telefono squilla. - 电话在响。", "Posso usare il telefono? - 我可以用电话吗？"]),
        ("484", "cellulare", "手机", "mobile phone", "tʃelluˈlaːre", "日常用语", "A1", ["Ho dimenticato il cellulare. - 我忘了手机。", "Il mio cellulare è scarico. - 我的手机没电了。"]),
        ("485", "computer", "电脑", "computer", "komˈpjuter", "工作学习", "A1", ["Il computer è acceso. - 电脑开着。", "Lavoro al computer. - 我在电脑上工作。"]),
        ("486", "internet", "互联网", "internet", "ˈinternet", "工作学习", "A1", ["Cerco su internet. - 我在网上搜索。", "C'è internet qui? - 这里有网吗？"]),
        ("487", "email", "电子邮件", "email", "iˈmeil", "工作学习", "A1", ["Ti mando un'email. - 我给你发邮件。", "Controlla la tua email. - 检查你的邮件。"]),
        ("488", "messaggio", "消息", "message", "mesˈsaddʒo", "日常用语", "A1", ["Ho ricevuto un messaggio. - 我收到一条消息。", "Mandami un messaggio. - 给我发条消息。"]),
        ("489", "chiamare", "打电话", "to call", "kjaˈmaːre", "日常用语", "A1", ["Ti chiamo dopo. - 我稍后给你打电话。", "Come ti chiami? - 你叫什么名字？"]),
        ("490", "rispondere", "回答", "to answer", "risˈpondere", "日常用语", "A1", ["Rispondi al telefono. - 接电话。", "Non so come rispondere. - 我不知道怎么回答。"]),

        # 感官动词 (ID 491-496)
        ("491", "ascoltare", "听", "to listen", "askolˈtaːre", "日常用语", "A1", ["Ascolto la musica. - 我听音乐。", "Ascoltami! - 听我说！"]),
        ("492", "guardare", "看", "to watch", "ɡwarˈdaːre", "日常用语", "A1", ["Guardo la TV. - 我看电视。", "Guardami! - 看着我！"]),
        ("493", "vedere", "看见", "to see", "veˈdeːre", "日常用语", "A1", ["Vedo un gatto. - 我看见一只猫。", "Non vedo bene. - 我看不清。"]),
        ("494", "sentire", "听到/感觉", "to hear/feel", "senˈtiːre", "日常用语", "A1", ["Sento un rumore. - 我听到一个声音。", "Come ti senti? - 你感觉怎么样？"]),
        ("495", "odore", "气味", "smell", "oˈdoːre", "日常用语", "A2", ["Che buon odore! - 好香啊！", "C'è uno strano odore. - 有一股奇怪的气味。"]),
        ("496", "sapore", "味道", "taste", "saˈpoːre", "食物餐饮", "A2", ["Che sapore ha? - 它是什么味道？", "Ha un buon sapore. - 味道很好。"]),

        # 颜色 (ID 497-508)
        ("497", "colore", "颜色", "color", "koˈloːre", "日常用语", "A1", ["Che colore preferisci? - 你喜欢什么颜色？", "Il mio colore preferito è il blu. - 我最喜欢的颜色是蓝色。"]),
        ("498", "rosso", "红色", "red", "ˈrosso", "日常用语", "A1", ["La mela è rossa. - 苹果是红色的。", "Mi piace il rosso. - 我喜欢红色。"]),
        ("499", "blu", "蓝色", "blue", "blu", "日常用语", "A1", ["Il cielo è blu. - 天空是蓝色的。", "Una camicia blu. - 一件蓝色衬衫。"]),
        ("500", "verde", "绿色", "green", "ˈverde", "日常用语", "A1", ["L'erba è verde. - 草是绿色的。", "Un vestito verde. - 一件绿色的裙子。"]),
        ("501", "giallo", "黄色", "yellow", "ˈdʒallo", "日常用语", "A1", ["Il sole è giallo. - 太阳是黄色的。", "I limoni sono gialli. - 柠檬是黄色的。"]),
        ("502", "nero", "黑色", "black", "ˈneːro", "日常用语", "A1", ["Un gatto nero. - 一只黑猫。", "Caffè nero. - 黑咖啡。"]),
        ("503", "bianco", "白色", "white", "ˈbjaŋko", "日常用语", "A1", ["La neve è bianca. - 雪是白色的。", "Una casa bianca. - 一座白色的房子。"]),
        ("504", "grigio", "灰色", "gray", "ˈɡriːdʒo", "日常用语", "A1", ["Un cielo grigio. - 灰色的天空。", "Pantaloni grigi. - 灰色裤子。"]),
        ("505", "marrone", "棕色", "brown", "marˈroːne", "日常用语", "A1", ["Occhi marroni. - 棕色的眼睛。", "Una borsa marrone. - 一个棕色的包。"]),
        ("506", "arancione", "橙色", "orange", "aranˈtʃoːne", "日常用语", "A1", ["Un'arancia arancione. - 一个橙色的橙子。", "Il tramonto è arancione. - 日落是橙色的。"]),
        ("507", "rosa", "粉色", "pink", "ˈrɔːza", "日常用语", "A1", ["Una maglietta rosa. - 一件粉色T恤。", "I fiori rosa. - 粉色的花。"]),
        ("508", "viola", "紫色", "purple", "ˈvjɔːla", "日常用语", "A1", ["Un fiore viola. - 一朵紫色的花。", "Mi piace il viola. - 我喜欢紫色。"]),

        # 形容词 - 大小高低 (ID 509-526)
        ("509", "grande", "大的", "big", "ˈɡrande", "日常用语", "A1", ["Una casa grande. - 一座大房子。", "È troppo grande. - 太大了。"]),
        ("510", "piccolo", "小的", "small", "ˈpikkolo", "日常用语", "A1", ["Un cane piccolo. - 一只小狗。", "La stanza è piccola. - 房间很小。"]),
        ("511", "alto", "高的", "tall", "ˈalto", "日常用语", "A1", ["Un uomo alto. - 一个高个子男人。", "La montagna è alta. - 山很高。"]),
        ("512", "basso", "矮的", "short", "ˈbasso", "日常用语", "A1", ["Un tavolo basso. - 一张矮桌子。", "È basso di statura. - 他个子矮。"]),
        ("513", "lungo", "长的", "long", "ˈluŋɡo", "日常用语", "A1", ["Capelli lunghi. - 长头发。", "Una strada lunga. - 一条长路。"]),
        ("514", "corto", "短的", "short", "ˈkɔrto", "日常用语", "A1", ["Capelli corti. - 短头发。", "Una gonna corta. - 一条短裙。"]),
        ("515", "largo", "宽的", "wide", "ˈlarɡo", "日常用语", "A2", ["Una strada larga. - 一条宽街道。", "Il letto è largo. - 床很宽。"]),
        ("516", "stretto", "窄的", "narrow", "ˈstretto", "日常用语", "A2", ["Una strada stretta. - 一条窄街。", "I pantaloni sono stretti. - 裤子很紧。"]),
        ("517", "pesante", "重的", "heavy", "peˈzante", "日常用语", "A2", ["La valigia è pesante. - 行李箱很重。", "Questo è troppo pesante. - 这太重了。"]),
        ("518", "leggero", "轻的", "light", "ledˈdʒɛːro", "日常用语", "A2", ["Una piuma è leggera. - 羽毛很轻。", "Un pasto leggero. - 清淡的一餐。"]),
        ("519", "forte", "强壮的", "strong", "ˈfɔrte", "日常用语", "A1", ["È molto forte. - 他很强壮。", "Un vento forte. - 强风。"]),
        ("520", "debole", "虚弱的", "weak", "ˈdɛːbole", "日常用语", "A2", ["Mi sento debole. - 我感觉虚弱。", "Una luce debole. - 微弱的光线。"]),
        ("521", "veloce", "快的", "fast", "veˈloːtʃe", "日常用语", "A1", ["Una macchina veloce. - 一辆快车。", "Cammina veloce. - 走快点。"]),
        ("522", "lento", "慢的", "slow", "ˈlɛnto", "日常用语", "A1", ["Sei troppo lento. - 你太慢了。", "Un treno lento. - 一列慢车。"]),
        ("523", "facile", "容易的", "easy", "ˈfaːtʃile", "日常用语", "A1", ["È molto facile. - 这很容易。", "Un esercizio facile. - 一个简单的练习。"]),
        ("524", "difficile", "困难的", "difficult", "difˈfiːtʃile", "日常用语", "A1", ["L'esame è difficile. - 考试很难。", "Non è difficile. - 这不难。"]),
        ("525", "possibile", "可能的", "possible", "posˈsiːbile", "日常用语", "A2", ["È possibile? - 这可能吗？", "Tutto è possibile. - 一切皆有可能。"]),
        ("526", "impossibile", "不可能的", "impossible", "imposˈsiːbile", "日常用语", "A2", ["È impossibile! - 这不可能！", "Una missione impossibile. - 一个不可能的任务。"]),

        # 形容词 - 性质 (ID 527-537)
        ("527", "importante", "重要的", "important", "imporˈtante", "日常用语", "A1", ["È molto importante. - 这很重要。", "Una decisione importante. - 一个重要的决定。"]),
        ("528", "interessante", "有趣的", "interesting", "interessˈsante", "日常用语", "A1", ["Un libro interessante. - 一本有趣的书。", "La storia è interessante. - 故事很有趣。"]),
        ("529", "noioso", "无聊的", "boring", "noˈjoːzo", "日常用语", "A2", ["Il film è noioso. - 电影很无聊。", "Una lezione noiosa. - 一堂无聊的课。"]),
        ("530", "divertente", "有趣的", "fun", "diverˈtente", "日常用语", "A1", ["Una festa divertente. - 一个有趣的派对。", "È molto divertente. - 这很好玩。"]),
        ("531", "strano", "奇怪的", "strange", "ˈstraːno", "日常用语", "A2", ["Che strano! - 真奇怪！", "Un comportamento strano. - 奇怪的行为。"]),
        ("532", "normale", "正常的", "normal", "norˈmaːle", "日常用语", "A2", ["È tutto normale. - 一切正常。", "Una vita normale. - 正常的生活。"]),
        ("533", "speciale", "特别的", "special", "speˈtʃaːle", "日常用语", "A2", ["Un giorno speciale. - 特别的一天。", "Offerta speciale. - 特价优惠。"]),
        ("534", "sicuro", "确定的", "sure", "siˈkuːro", "日常用语", "A2", ["Sei sicuro? - 你确定吗？", "È un posto sicuro. - 这是一个安全的地方。"]),
        ("535", "pericoloso", "危险的", "dangerous", "perikoˈloːzo", "日常用语", "A2", ["È pericoloso! - 很危险！", "Una situazione pericolosa. - 危险的情况。"]),
        ("536", "vicino", "近的", "near", "viˈtʃiːno", "日常用语", "A1", ["La fermata è vicina. - 车站很近。", "Abito qui vicino. - 我住在附近。"]),
        ("537", "lontano", "远的", "far", "lonˈtaːno", "日常用语", "A1", ["È molto lontano. - 很远。", "Vivo lontano da qui. - 我住得离这里很远。"]),

        # 方位介词 (ID 538-548)
        ("538", "davanti", "前面", "in front", "daˈvanti", "日常用语", "A1", ["Davanti alla casa. - 在房子前面。", "Siediti davanti. - 坐在前面。"]),
        ("539", "dietro", "后面", "behind", "ˈdjɛːtro", "日常用语", "A1", ["Dietro la porta. - 在门后面。", "Cammina dietro di me. - 走在我后面。"]),
        ("540", "sopra", "上面", "above", "ˈsoːpra", "日常用语", "A1", ["Sopra il tavolo. - 在桌子上面。", "Al piano di sopra. - 在楼上。"]),
        ("541", "sotto", "下面", "under", "ˈsotto", "日常用语", "A1", ["Sotto il letto. - 在床下面。", "Al piano di sotto. - 在楼下。"]),
        ("542", "dentro", "里面", "inside", "ˈdentro", "日常用语", "A1", ["Dentro la scatola. - 在盒子里面。", "Vieni dentro. - 进来。"]),
        ("543", "fuori", "外面", "outside", "ˈfwɔːri", "日常用语", "A1", ["Fuori dalla casa. - 在房子外面。", "Andiamo fuori. - 我们出去。"]),
        ("544", "accanto", "旁边", "next to", "akˈkanto", "日常用语", "A1", ["Accanto alla banca. - 在银行旁边。", "Siediti accanto a me. - 坐在我旁边。"]),
        ("545", "tra", "之间", "between", "tra", "日常用语", "A1", ["Tra la casa e la scuola. - 在家和学校之间。", "Tra cinque minuti. - 五分钟后。"]),
        ("546", "contro", "反对", "against", "ˈkontro", "日常用语", "A2", ["Contro il muro. - 靠着墙。", "Sono contro questa idea. - 我反对这个主意。"]),
        ("547", "verso", "朝向", "towards", "ˈvɛrso", "日常用语", "A2", ["Verso casa. - 朝家的方向。", "Verso le otto. - 大约8点。"]),
        ("548", "attraverso", "穿过", "through", "attraˈvɛrso", "日常用语", "A2", ["Attraverso il parco. - 穿过公园。", "Guardo attraverso la finestra. - 我透过窗户看。"]),

        # 时间副词 (ID 549-565)
        ("549", "finalmente", "终于", "finally", "finalˈmente", "日常用语", "A2", ["Finalmente sei arrivato! - 你终于到了！", "Finalmente è finito. - 终于结束了。"]),
        ("550", "ancora", "还", "still", "aŋˈkoːra", "日常用语", "A1", ["Sei ancora qui? - 你还在这里？", "Non ancora. - 还没有。"]),
        ("551", "già", "已经", "already", "dʒa", "日常用语", "A1", ["Ho già mangiato. - 我已经吃过了。", "Sei già pronto? - 你已经准备好了吗？"]),
        ("552", "subito", "马上", "immediately", "ˈsuːbito", "日常用语", "A1", ["Vengo subito. - 我马上来。", "Fallo subito! - 马上做！"]),
        ("553", "presto", "早/快", "early/soon", "ˈprɛsto", "日常用语", "A1", ["È troppo presto. - 太早了。", "A presto! - 回头见！"]),
        ("554", "tardi", "晚", "late", "ˈtardi", "日常用语", "A1", ["È troppo tardi. - 太晚了。", "Arrivo tardi. - 我迟到了。"]),
        ("555", "sempre", "总是", "always", "ˈsempre", "日常用语", "A1", ["Sei sempre puntuale. - 你总是很准时。", "Per sempre. - 永远。"]),
        ("556", "mai", "从不", "never", "mai", "日常用语", "A1", ["Non ci vado mai. - 我从不去那里。", "Sei mai stato in Italia? - 你去过意大利吗？"]),
        ("557", "spesso", "经常", "often", "ˈspesso", "日常用语", "A1", ["Vado spesso al cinema. - 我经常去电影院。", "Capita spesso. - 经常发生。"]),
        ("558", "raramente", "很少", "rarely", "raraˈmente", "日常用语", "A2", ["Raramente mangio carne. - 我很少吃肉。", "Succede raramente. - 很少发生。"]),
        ("559", "qualche volta", "有时候", "sometimes", "ˈkwalke ˈvɔlta", "日常用语", "A1", ["Qualche volta vado a correre. - 我有时候去跑步。", "Ci vediamo qualche volta. - 我们有时候见面。"]),
        ("560", "forse", "也许", "maybe", "ˈforse", "日常用语", "A1", ["Forse domani. - 也许明天。", "Forse hai ragione. - 也许你是对的。"]),
        ("561", "certamente", "当然", "certainly", "tʃertaˈmente", "日常用语", "A2", ["Certamente! - 当然！", "Verrò certamente. - 我当然会来。"]),
        ("562", "probabilmente", "大概", "probably", "probabilˈmente", "日常用语", "A2", ["Probabilmente pioverà. - 可能会下雨。", "Arriverà probabilmente domani. - 他大概明天到。"]),
        ("563", "veramente", "真的", "really", "veraˈmente", "日常用语", "A2", ["Veramente? - 真的吗？", "È veramente bello. - 真的很美。"]),
        ("564", "naturalmente", "自然地", "naturally", "naturalˈmente", "日常用语", "A2", ["Naturalmente! - 当然！", "Succede naturalmente. - 自然发生。"]),
        ("565", "esattamente", "确切地", "exactly", "ezattaˈmente", "日常用语", "A2", ["Esattamente! - 正是！", "Cosa esattamente? - 确切地说是什么？"]),

        # 程度副词 (ID 566-573)
        ("566", "solamente", "仅仅", "only", "solaˈmente", "日常用语", "A2", ["Solamente due euro. - 只要两欧元。", "Voglio solamente aiutare. - 我只是想帮忙。"]),
        ("567", "abbastanza", "足够", "enough", "abbasˈtantsa", "日常用语", "A2", ["È abbastanza grande. - 够大了。", "Abbastanza bene. - 相当好。"]),
        ("568", "troppo", "太", "too much", "ˈtroppo", "日常用语", "A1", ["È troppo caro. - 太贵了。", "Mangi troppo. - 你吃得太多了。"]),
        ("569", "poco", "少", "little", "ˈpɔːko", "日常用语", "A1", ["Un po' di zucchero. - 一点糖。", "Mangio poco. - 我吃得少。"]),
        ("570", "molto", "很", "very", "ˈmolto", "日常用语", "A1", ["Molto bene! - 非常好！", "Ti amo molto. - 我非常爱你。"]),
        ("571", "tanto", "这么多", "so much", "ˈtanto", "日常用语", "A2", ["Grazie tante! - 非常感谢！", "Non è tanto difficile. - 没那么难。"]),
        ("572", "quasi", "几乎", "almost", "ˈkwaːzi", "日常用语", "A2", ["È quasi pronto. - 几乎准备好了。", "Quasi tutti. - 几乎所有人。"]),
        ("573", "insieme", "一起", "together", "inˈsjɛːme", "日常用语", "A1", ["Andiamo insieme. - 我们一起去。", "Lavoriamo insieme. - 我们一起工作。"]),

        # 常用副词和连词 (ID 574-590)
        ("574", "solo", "单独", "alone", "ˈsoːlo", "日常用语", "A1", ["Vivo da solo. - 我独自生活。", "Solo tu. - 只有你。"]),
        ("575", "anche", "也", "also", "ˈaŋke", "日常用语", "A1", ["Anch'io! - 我也是！", "Voglio anche questo. - 我也要这个。"]),
        ("576", "invece", "相反", "instead", "inˈveːtʃe", "日常用语", "A2", ["Invece di studiare. - 不学习反而。", "Io invece penso... - 而我却认为..."]),
        ("577", "allora", "那么", "then", "alˈloːra", "日常用语", "A1", ["Allora andiamo! - 那么我们走吧！", "E allora? - 那又怎样？"]),
        ("578", "quindi", "因此", "therefore", "ˈkwindi", "日常用语", "A2", ["Quindi è vero. - 因此这是真的。", "Non so, quindi aspetto. - 我不知道，所以我等待。"]),
        ("579", "però", "但是", "however", "peˈrɔ", "日常用语", "A1", ["È bello, però caro. - 很漂亮，但是贵。", "Capisco, però... - 我明白，但是..."]),
        ("580", "perché", "为什么", "why", "perˈke", "日常用语", "A1", ["Perché non vieni? - 你为什么不来？", "Perché sono stanco. - 因为我累了。"]),
        ("581", "quando", "什么时候", "when", "ˈkwando", "日常用语", "A1", ["Quando parti? - 你什么时候出发？", "Quando arrivo, ti chiamo. - 当我到达时，我给你打电话。"]),
        ("582", "dove", "哪里", "where", "ˈdoːve", "日常用语", "A1", ["Dove vai? - 你去哪里？", "Dove abiti? - 你住在哪里？"]),
        ("583", "come", "怎么", "how", "ˈkoːme", "日常用语", "A1", ["Come stai? - 你好吗？", "Come si dice? - 怎么说？"]),
        ("584", "cosa", "什么", "what", "ˈkɔːza", "日常用语", "A1", ["Cosa fai? - 你在做什么？", "Cosa vuoi? - 你想要什么？"]),
        ("585", "chi", "谁", "who", "ki", "日常用语", "A1", ["Chi sei? - 你是谁？", "Chi viene? - 谁来？"]),
        ("586", "quale", "哪个", "which", "ˈkwaːle", "日常用语", "A1", ["Quale preferisci? - 你更喜欢哪个？", "Quale libro? - 哪本书？"]),
        ("587", "quanto", "多少", "how much", "ˈkwanto", "日常用语", "A1", ["Quanto costa? - 多少钱？", "Quanto tempo? - 多长时间？"]),
        ("588", "niente", "没什么", "nothing", "ˈnjɛnte", "日常用语", "A1", ["Non c'è niente. - 什么都没有。", "Niente di speciale. - 没什么特别的。"]),
        ("589", "tutto", "全部", "everything", "ˈtutto", "日常用语", "A1", ["Va tutto bene. - 一切都好。", "Tutti i giorni. - 每天。"]),
        ("590", "qualcuno", "某人", "someone", "kwalˈkuːno", "日常用语", "A2", ["C'è qualcuno? - 有人吗？", "Qualcuno lo sa. - 有人知道。"]),

        # 不定代词 (ID 591-600)
        ("591", "nessuno", "没有人", "nobody", "nesˈsuːno", "日常用语", "A2", ["Non c'è nessuno. - 没有人。", "Nessuno lo sa. - 没人知道。"]),
        ("592", "qualcosa", "某事", "something", "kwalˈkɔːza", "日常用语", "A1", ["Vuoi qualcosa? - 你想要什么吗？", "C'è qualcosa di nuovo. - 有新的东西。"]),
        ("593", "ognuno", "每个人", "everyone", "oɲˈɲuːno", "日常用语", "A2", ["Ognuno ha il suo. - 每个人都有自己的。", "Per ognuno di voi. - 给你们每个人。"]),
        ("594", "stesso", "同样的", "same", "ˈstesso", "日常用语", "A2", ["La stessa cosa. - 同样的事情。", "Io stesso. - 我自己。"]),
        ("595", "altro", "其他的", "other", "ˈaltro", "日常用语", "A1", ["Un altro caffè. - 再来一杯咖啡。", "Gli altri amici. - 其他朋友。"]),
        ("596", "ogni", "每个", "every", "ˈɔɲɲi", "日常用语", "A1", ["Ogni giorno. - 每天。", "Ogni persona. - 每个人。"]),
        ("597", "alcuni", "一些", "some", "alˈkuːni", "日常用语", "A2", ["Alcuni amici. - 一些朋友。", "In alcuni casi. - 在一些情况下。"]),
        ("598", "parecchi", "好几个", "several", "paˈrekkji", "日常用语", "A2", ["Parecchi giorni. - 好几天。", "Parecchie persone. - 相当多的人。"]),
        ("599", "proprio", "正好", "just", "ˈprɔːprjo", "日常用语", "A2", ["Proprio così. - 正是如此。", "Proprio qui. - 就在这里。"]),
        ("600", "nulla", "无/没有", "nothing", "ˈnulla", "日常用语", "A2", ["Non serve a nulla. - 没有用。", "Nulla di importante. - 没什么重要的。"]),
    ]

    # 转换为完整的词汇格式
    for item in new_words_data:
        word_id, italian, chinese, english, pronunciation, category, level, examples = item
        new_word = {
            "id": word_id,
            "italian": italian,
            "chinese": chinese,
            "english": english,
            "pronunciation": pronunciation,
            "category": category,
            "level": level,
            "createdAt": "2024-01-22T00:00:00.000Z",
            "examples": examples
        }
        words.append(new_word)

    # 写回文件
    with open('assets/data/sample_words.json', 'w', encoding='utf-8') as f:
        json.dump(words, f, ensure_ascii=False, indent=2)

    print(f"✅ 成功添加 {len(new_words_data)} 个新词汇！")
    print(f"📊 总词汇量: {len(words)}")
    print(f"🎯 词汇范围: ID 1 - {words[-1]['id']}")

    # 统计各等级词汇数量
    level_counts = {}
    for word in words:
        level = word['level']
        level_counts[level] = level_counts.get(level, 0) + 1

    print("\n📈 各等级词汇数量:")
    for level in sorted(level_counts.keys()):
        print(f"  {level}: {level_counts[level]} 个")

if __name__ == '__main__':
    main()
