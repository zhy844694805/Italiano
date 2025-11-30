#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
补充A1必需的高频词汇
针对CEFR A1标准缺失的核心主题词汇：时间、地点、交通工具、职业等
"""

import json
from datetime import datetime

def load_existing_words():
    """加载现有词汇数据"""
    try:
        with open('assets/data/sample_words.json', 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print("错误: 找不到 sample_words.json 文件")
        return []

def get_next_id(existing_words):
    """获取下一个可用ID"""
    if not existing_words:
        return "1"
    max_id = max(int(word['id']) for word in existing_words)
    return str(max_id + 1)

def create_word_data(id, italian, chinese, english, pronunciation, category, examples):
    """创建标准词汇数据格式"""
    return {
        "id": id,
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": category,
        "level": "A1",
        "createdAt": datetime.now().isoformat() + ".000Z",
        "examples": examples,
        "audioUrl": f"assets/audio/words/{id}.mp3",
        "imageUrl": None
    }

def generate_essential_a1_words(next_id):
    """生成A1必需的高频词汇"""

    # 1. 时间相关词汇 (40个)
    time_words = [
        # 数字 11-100
        ("undici", "十一", "eleven", "ˈunditʃi", "数字", ["Ho undici anni. - 我11岁。", "Undici più undici fa ventidue. - 11加11等于22。"]),
        ("dodici", "十二", "twelve", "ˈdoditʃi", "数字", ["Sono le dodici. - 12点了。", "Dodici mesi in un anno. - 一年12个月。"]),
        ("tredici", "十三", "thirteen", "tredˈitʃi", "数字", ["Oggi è tredici. - 今天是13号。", "Tredici persone. - 13个人。"]),
        ("quattordici", "十四", "fourteen", "kwattorˈditʃi", "数字", ["Ho quattordici libri. - 我有14本书。", "Quattordici anni. - 14岁。"]),
        ("quindici", "十五", "fifteen", "ˈkwinditʃi", "数字", ["Sono le quindici. - 15点。", "Quindici minuti. - 15分钟。"]),
        ("venti", "二十", "twenty", "vɛnti", "数字", ["Venti euro. - 20欧元。", "Ho venti anni. - 我20岁。"]),
        ("trenta", "三十", "thirty", "trɛnta", "数字", ["Sono le trenta. - 30点。", "Trenta studenti. - 30个学生。"]),
        ("quaranta", "四十", "forty", "kwarˈanta", "数字", ["Quaranta gradi. - 40度。", "Ho quaranta anni. - 我40岁。"]),
        ("cinquanta", "五十", "fifty", "tʃinˈkwanta", "数字", ["Cinquanta euro. - 50欧元。", "Cinquanta minuti. - 50分钟。"]),
        ("sessanta", "六十", "sixty", "sɛssˈanta", "数字", ["Sessanta chilometri. - 60公里。", "Ho sessanta anni. - 我60岁。"]),
        ("settanta", "七十", "seventy", "sɛtˈtanta", "数字", ["Settanta euro. - 70欧元。", "Settanta persone. - 70个人。"]),
        ("ottanta", "八十", "eighty", "otˈtanta", "数字", ["Ottanta anni. - 80年。", "Ottanta chili. - 80公斤。"]),
        ("novanta", "九十", "ninety", "noˈvanta", "数字", ["Novanta euro. - 90欧元。", "Novanta chilometri. - 90公里。"]),
        ("cento", "一百", "one hundred", "tʃɛnto", "数字", ["Cento euro. - 100欧元。", "Cento metri. - 100米。"]),

        # 星期和月份
        ("lunedì", "星期一", "Monday", "lunɛˈdi", "星期", ["Lunedì vado a scuola. - 星期一我去上学。", "Il lunedì è il primo giorno. - 星期一是第一天。"]),
        ("martedì", "星期二", "Tuesday", "marˈtɛdi", "星期", ["Martedì ho una riunione. - 星期二我有个会议。", "Martedì prossimo. - 下星期二。"]),
        ("mercoledì", "星期三", "Wednesday", "mɛrkolɛˈdi", "星期", ["Mercoledì vado al cinema. - 星期三我去看电影。", "Il mercoledì. - 星期三。"]),
        ("giovedì", "星期四", "Thursday", "dʒovɛˈdi", "星期", ["Giovedì lavoro fino alle sei. - 星期四我工作到6点。", "Il giovedì. - 星期四。"]),
        ("venerdì", "星期五", "Friday", "vɛnɛrˈdi", "星期", ["Venerdì sera esco con amici. - 星期五晚上我和朋友出去。", "Venerdì prossimo. - 下星期五。"]),
        ("sabato", "星期六", "Saturday", "sabato", "星期", ["Sabato vado al mercato. - 星期六我去市场。", "Buon sabato! - 周末愉快！"]),
        ("domenica", "星期日", "Sunday", "domɛˈnika", "星期", ["Domenica riposo. - 星期天我休息。", "La domenica. - 星期天。"]),

        ("gennaio", "一月", "January", "dʒɛnˈnaio", "月份", ["Gennaio è freddo. - 一月很冷。", "Il primo gennaio. - 1月1日。"]),
        ("febbraio", "二月", "February", "fɛbˈbraio", "月份", ["Febbraio ha ventotto giorni. - 二月有28天。", "Il febbraio. - 二月。"]),
        ("marzo", "三月", "March", "martso", "月份", ["Marzo inizia la primavera. - 三月春天开始。", "Marzo 2024. - 2024年3月。"]),
        ("aprile", "四月", "April", "aˈprile", "月份", ["Aprile è un mese bello. - 四月是个美丽的月份。", "Buon aprile! - 四月快乐！"]),
        ("maggio", "五月", "May", "maddʒo", "月份", ["Maggio è il mio mese preferito. - 五月是我最喜欢的月份。", "Il primo maggio. - 5月1日。"]),
        ("giugno", "六月", "June", "dʒuˈnjo", "月份", ["Giugno è molto caldo. - 六月很热。", "Il giugno. - 六月。"]),
        ("luglio", "七月", "July", "luˈljo", "月份", ["Luglio è il mese delle vacanze. - 七月是度假的月份。", "Luglio 2024. - 2024年7月。"]),
        ("agosto", "八月", "August", "aˈgosto", "月份", ["Ad agosto vado al mare. - 八月我去海边。", "L'agosto. - 八月。"]),
        ("settembre", "九月", "September", "sɛtˈtɛmbre", "月份", ["Settembre inizia l'autunno. - 九月秋天开始。", "Settembre 2024. - 2024年9月。"]),
        ("ottobre", "十月", "October", "otˈtobre", "月份", ["Ottobre è il mese dei colori. - 十月是多彩的季节。", "Primo ottobre. - 10月1日。"]),
        ("novembre", "十一月", "November", "novɛmbre", "月份", ["Novembre è freddo. - 十一月很冷。", "Il novembre. - 十一月。"]),
        ("dicembre", "十二月", "December", "ditʃɛmbre", "月份", ["Dicembre è il mese del Natale. - 十二月是圣诞节。", "Buon dicembre! - 十二月快乐！"]),

        # 时间表达
        ("ora", "小时/现在", "hour/now", "ˈora", "时间", ["Che ora è? - 现在几点？", "Un'ora fa. - 一小时前。"]),
        ("minuto", "分钟", "minute", "miˈnuto", "时间", ["Aspetta un minuto. - 等一分钟。", "Cinque minuti. - 5分钟。"]),
        ("giorno", "天/白天", "day", "dʒorno", "时间", ["Buon giorno! - 日安！", "Un giorno bello. - 好天气的一天。"]),
        ("settimana", "星期/周", "week", "sɛtˈtimana", "时间", ["Una settimana. - 一周。", "La prossima settimana. - 下周。"]),
        ("mese", "月", "month", "mɛze", "时间", ["Questo mese. - 这个月。", "Un mese fa. - 一个月前。"]),
        ("anno", "年", "year", "anno", "时间", ["Buon anno! - 新年快乐！", "Un anno fa. - 一年前。"]),
        ("mattina", "早上", "morning", "matˈtina", "时间", ["La mattina vado a lavoro. - 早上我去工作。", "Buona mattina! - 早上好！"]),
        ("pomeriggio", "下午", "afternoon", "pomɛrˈiddʒo", "时间", ["Il pomeriggio studio. - 下午我学习。", "Buon pomeriggio! - 下午好！"]),
        ("sera", "晚上", "evening", "sɛra", "时间", ["La sera guardo la TV. - 晚上看电视。", "Buona sera! - 晚上好！"]),
        ("notte", "夜晚", "night", "nɔtɛ", "时间", ["Buona notte! - 晚安！", "La notte è buia. - 夜晚很黑。"]),
    ]

    # 2. 城市地点和建筑物 (35个)
    places_words = [
        ("banca", "银行", "bank", "banka", "城市设施", ["Vado in banca. - 我去银行。", "La banca è chiusa. - 银行关门了。"]),
        ("ospedale", "医院", "hospital", "ospedˈale", "城市设施", ["Mio padre è in ospedale. - 我父亲在医院。", "L'ospedale è grande. - 医院很大。"]),
        ("scuola", "学校", "school", "skwɔla", "城市设施", ["Vado a scuola. - 我去上学。", "La scuola è lontana. - 学校很远。"]),
        ("università", "大学", "university", "universita", "城市设施", ["Studio all'università. - 我在大学学习。", "L'università è importante. - 大学很重要。"]),
        ("supermercato", "超市", "supermarket", "supermɛrkato", "购物", ["Compro al supermercato. - 我在超市购物。", "Il supermercato è aperto. - 超市营业。"]),
        ("negozio", "商店", "shop/store", "nɛˈɡodzio", "购物", ["Vado al negozio. - 我去商店。", "Il negozio di abbigliamento. - 服装店。"]),
        ("panificio", "面包店", "bakery", "panifitʃo", "购物", ["Compro il pane al panificio. - 我在面包店买面包。", "Il panificio è vicino. - 面包店很近。"]),
        ("ristorante", "餐厅", "restaurant", "ristorˈante", "餐饮", ["Ceno al ristorante. - 我在餐厅吃晚饭。", "Il ristorante è buono. - 餐厅很好。"]),
        ("bar", "酒吧/咖啡馆", "bar/cafè", "bar", "餐饮", ["Prendo un caffè al bar. - 我在酒吧喝咖啡。", "Il bar è aperto. - 酒吧营业。"]),
        ("pizzeria", "披萨店", "pizzeria", "pittsɛˈria", "餐饮", ["Mangio la pizza. - 我吃披萨。", "La pizzeria è famosa. - 披萨店很出名。"]),
        ("hotel", "酒店", "hotel", "oˈtɛl", "住宿", ["Alloggio in hotel. - 我住酒店。", "L'hotel è di lusso. - 豪华酒店。"]),
        ("museo", "博物馆", "museum", "muˈzɛo", "文化", ["Visito il museo. - 我参观博物馆。", "Il museo d'arte. - 艺术博物馆。"]),
        ("teatro", "剧院", "theater", "tɛˈatro", "文化", ["Vado al teatro. - 我去剧院。", "Il teatro è vecchio. - 剧院很古老。"]),
        ("cinema", "电影院", "cinema", "tʃinɛma", "娱乐", ["Vado al cinema. - 我去看电影。", "Il cinema è pieno. - 电影院满了。"]),
        ("parco", "公园", "park", "parco", "休闲", ["Faccio una passeggiata nel parco. - 我在公园散步。", "Il parco è bello. - 公园很美。"]),
        ("chiesa", "教堂", "church", "kjɛsa", "宗教", ["La chiesa è antica. - 教堂很古老。", "Vado in chiesa. - 我去教堂。"]),
        ("stazione", "车站", "station", "statˈtsjone", "交通", ["Aspetto alla stazione. - 我在车站等待。", "La stazione ferroviaria. - 火车站。"]),
        ("aeroporto", "机场", "airport", "aɛrˈporto", "交通", ["L'aereo parte dall'aeroporto. - 飞机从机场起飞。", "L'aeroporto internazionale. - 国际机场。"]),
        ("metro", "地铁", "subway/metro", "mɛtro", "交通", ["Prendo la metro. - 我坐地铁。", "La stazione della metro. - 地铁站。"]),
        ("farmacia", "药店/药房", "pharmacy", "farmatʃa", "健康", ["Comprare medicine in farmacia. - 在药房买药。", "La farmacia è aperta. - 药房营业。"]),
        ("biblioteca", "图书馆", "library", "bibliotɛka", "学习", ["Studio in biblioteca. - 我在图书馆学习。", "La biblioteca è silenziosa. - 图书馆很安静。"]),
        ("piscina", "游泳池", "swimming pool", "piʃˈina", "运动", ["Vado in piscina. - 我去游泳池。", "La piscina è grande. - 游泳池很大。"]),
        ("palestra", "健身房", "gym", "palˈɛsra", "运动", ["Mi alleno in palestra. - 我在健身房锻炼。", "La palestra è moderna. - 健身房很现代。"]),
        ("stadio", "体育场", "stadium", "stadˈjo", "运动", ["Gioco allo stadio. - 我在体育场打球。", "Lo stadio di calcio. - 足球场。"]),
        ("ufficio", "办公室", "office", "ufˈfitʃo", "工作", ["Lavoro in ufficio. - 我在办公室工作。", "L'ufficio è al secondo piano. - 办公室在二楼。"]),
        ("casa", "家/房子", "home/house", "kasa", "居住", ["Torno a casa. - 我回家。", "La mia casa è grande. - 我的房子很大。"]),
        ("appartamento", "公寓", "apartment", "appartamɛnto", "居住", ["Vivo in un appartamento. - 我住在公寓里。", "L'appartamento è piccolo. - 公寓很小。"]),
        ("cucina", "厨房", "kitchen", "kuˈtʃina", "房间", ["Cucino nella cucina. - 我在厨房做饭。", "La cucina è pulita. - 厨房很干净。"]),
        ("camera", "房间", "room", "kamɛra", "房间", ["La mia camera è piccola. - 我的房间很小。", "Camera da letto. - 卧室。"]),
        ("soggiorno", "客厅", "living room", "soddʒorno", "房间", ["Guardiamo TV in soggiorno. - 我们在客厅看电视。", "Il soggiorno è accogliente. - 客厅很温馨。"]),
        ("bagno", "浴室", "bathroom", "baɲo", "房间", ["Mi lavo in bagno. - 我在浴室洗漱。", "Il bagno è piccolo. - 浴室很小。"]),
        ("giardino", "花园", "garden", "dʒardino", "户外", ["Leggo in giardino. - 我在花园阅读。", "Il giardino è fiorito. - 花园鲜花盛开。"]),
        ("garage", "车库", "garage", "garadʒ", "房屋", ["La macchina è nel garage. - 车在车库里。", "Il garage è pieno. - 车库满了。"]),
        ("posto", "地方/位置", "place/seat", "posto", "方位", ["Questo posto è libero. - 这个位置是空的。", "Un posto bello. - 一个美丽的地方。"]),
        ("indirizzo", "地址", "address", "indirittso", "方位", ["Il mio indirizzo è Via Roma. - 我的地址是罗马路。", "Qual è il tuo indirizzo? - 你的地址是什么？"]),
    ]

    # 3. 交通工具和出行 (25个)
    transport_words = [
        ("macchina", "汽车", "car", "makkina", "交通", ["Guido la macchina. - 我开车。", "La macchina è nuova. - 汽车是新的。"]),
        ("automobile", "汽车", "automobile", "automɔbile", "交通", ["L'automobile è veloce. - 汽车很快。", "Compro un'automobile. - 我买一辆汽车。"]),
        ("treno", "火车", "train", "trɛno", "交通", ["Viaggio in treno. - 我乘火车旅行。", "Il treno parte alle 9. - 火车9点出发。"]),
        ("autobus", "公交车", "bus", "autobus", "交通", ["Prendo l'autobus. - 我坐公交车。", "L'autobus è pieno. - 公交车很挤。"]),
        ("bicicletta", "自行车", "bicycle", "bitʃiklɛtta", "交通", ["Vado in bicicletta. - 我骑自行车。", "La bicicletta è rossa. - 自行车是红色的。"]),
        ("moto", "摩托车", "motorcycle", "mɔto", "交通", ["Guido la moto. - 我骑摩托车。", "La moto è veloce. - 摩托车很快。"]),
        ("aereo", "飞机", "airplane", "aɛrɛo", "交通", ["Viaggio in aereo. - 我乘飞机旅行。", "L'aereo vola alto. - 飞机飞得很高。"]),
        ("barca", "小船", "boat", "barka", "交通", ["Vado in barca. - 我坐船。", "La barca a vela. - 帆船。"]),
        ("nave", "轮船", "ship", "nave", "交通", ["La nave è nel porto. - 轮船在港口。", "Viaggio in nave. - 我乘船旅行。"]),
        ("metropolitana", "地铁", "subway", "mɛtropolitana", "交通", ["Prendo la metropolitana. - 我坐地铁。", "La metropolitana è veloce. - 地铁很快。"]),
        ("taxi", "出租车", "taxi", "taksi", "交通", ["Chiamo un taxi. - 我叫出租车。", "Il taxi è giallo. - 出租车是黄色的。"]),
        ("biglietto", "票", "ticket", "bidʒɛtto", "出行", ["Compro un biglietto. - 我买票。", "Il biglietto costa 10 euro. - 票价10欧元。"]),
        ("passaporto", "护照", "passport", "passaporto", "出行", ["Mostro il passaporto. - 我出示护照。", "Il mio passaporto è valido. - 我的护照有效。"]),
        ("valigia", "行李箱", "suitcase", "validʒa", "出行", ["Preparo la valigia. - 我准备行李箱。", "La valigia è pesante. - 行李箱很重。"]),
        ("bagaglio", "行李", "luggage", "badʒallo", "出行", ["Il mio bagaglio. - 我的行李。", "Aereo con bagaglio. - 带行李的飞机。"]),
        ("passeggero", "乘客", "passenger", "passɛddʒɛro", "出行", ["Sono un passeggero. - 我是一名乘客。", "I passeggeri aspettano. - 乘客们等待。"]),
        ("pilota", "飞行员", "pilot", "pilota", "职业", ["Il pilota guida l'aereo. - 飞行员驾驶飞机。", "Il pilota è esperto. - 飞行员经验丰富。"]),
        ("autista", "司机", "driver", "autista", "职业", ["L'autista guida il taxi. - 司机驾驶出租车。", "L'autista è gentile. - 司机很友善。"]),
        ("viaggio", "旅行", "trip/travel", "viaddʒo", "出行", ["Faccio un viaggio. - 我去旅行。", "Un viaggio bello. - 一次美好的旅行。"]),
        ("vacanza", "假期", "vacation/holiday", "vakantʦa", "出行", ["Sono in vacanza. - 我在度假。", "Buone vacanze! - 假期愉快！"]),
        ("partire", "出发/离开", "to leave/depart", "partirɛ", "动词", ["Parto domani. - 我明天出发。", "Il treno parte alle 10. - 火车10点出发。"]),
        ("arrivare", "到达", "to arrive", "arrivarɛ", "动词", ["Arrivo presto. - 我很早到达。", "L'aereo arrive tra un'ora. - 飞机一小时后到达。"]),
        ("guidare", "驾驶", "to drive", "guidarɛ", "动词", ["So guidare la macchina. - 我会开车。", "Guida con attenzione. - 小心驾驶。"]),
        ("viaggiare", "旅行", "to travel", "viaddʒarɛ", "动词", ["Mi piace viaggiare. - 我喜欢旅行。", "Viaggiare è bello. - 旅行很美好。"]),
        ("salire", "上车", "to get on", "salirɛ", "动词", ["Salire sull'autobus. - 上公交车。", "Salgo in macchina. - 我上车。"]),
        ("scendere", "下车", "to get off", "ʃɛndɛrɛ", "动词", ["Scendo alla prossima fermata. - 我在下一站下车。", "Scendere dall'autobus. - 下公交车。"]),
    ]

    # 4. 职业和工作 (30个)
    jobs_words = [
        ("dottore", "医生", "doctor", "dottɔrɛ", "职业", ["Il dottore cura i pazienti. - 医生治疗病人。", "Vado dal dottore. - 我去看医生。"]),
        ("medico", "医生", "doctor", "mɛdiko", "职业", ["Il medico è gentile. - 医生很友善。", "Il medico mi visita. - 医生给我看病。"]),
        ("infermiera", "护士", "nurse", "infɛrmjɛra", "职业", ["L'infermiera aiuta i pazienti. - 护士帮助病人。", "L'infermiera è gentile. - 护士很友善。"]),
        ("insegnante", "教师", "teacher", "insɛɡnantɛ", "职业", ["L'insegnante spiega la lezione. - 老师讲解课程。", "L'insegnante è bravo. - 老师很棒。"]),
        ("studente", "学生", "student", "studɛntɛ", "身份", ["Sono studente. - 我是学生。", "Lo studente studia molto. - 这个学生学习很努力。"]),
        ("studentessa", "女学生", "female student", "studɛntɛssa", "身份", ["La studentessa è brava. - 这个女学生很棒。", "Le studentesse studiano. - 女学生们在学习。"]),
        ("lavoratore", "工人", "worker", "lavɔratɔrɛ", "职业", ["Il lavoratore è stanco. - 工人很累。", "I lavoratori partono. - 工人们出发了。"]),
        ("impiegato", "职员", "employee", "implɛgato", "职业", ["L'impiegato lavora in ufficio. - 职员在办公室工作。", "Gli impiegati pranzano. - 职员们吃午饭。"]),
        ("commerciante", "商人", "merchant", "kommɛrtʃantɛ", "职业", ["Il commerciante vende prodotti. - 商人销售产品。", "Il commerciante è ricco. - 商人很富有。"]),
        ("artigiano", "工匠", "craftsman", "artidʒano", "职业", ["L'artigiano crea oggetti. - 工匠制作物品。", "L'artigiano è abile. - 工匠技术娴熟。"]),
        ("cuoco", "厨师", "cook", "kuoko", "职业", ["Il cu cucina la pasta. - 厨师煮意面。", "Il cuoco è professionale. - 厨师很专业。"]),
        ("pasticcere", "糕点师", "pastry chef", "pastittʃɛrɛ", "职业", ["Il pasticcere fa dolci. - 糕点师做甜点。", "Il pasticcere è bravo. - 糕点师很棒。"]),
        ("cameriere", "服务员", "waiter", "kamɛrjɛrɛ", "职业", ["Il cameriere serve i clienti. - 服务员服务顾客。", "Il cameriere è gentile. - 服务员很友善。"]),
        ("cameriera", "女服务员", "waitress", "kamɛrjɛra", "职业", ["La cameriera porta il cibo. - 女服务员端来食物。", "La cameriera è gentile. - 女服务员很友善。"]),
        ("pizzaiolo", "披萨师", "pizza maker", "pitsaiɔlo", "职业", ["Il pizzaiolo prepara la pizza. - 披萨师准备披萨。", "Il pizzaiolo è veloce. - 披萨师动作很快。"]),
        ("barista", "酒吧服务员", "barista", "barista", "职业", ["Il barista prepara il caffè. - 酒吧服务员准备咖啡。", "La barista è gentile. - 酒吧女服务员很友善。"]),
        ("libraio", "书店老板", "bookseller", "libraio", "职业", ["Il libraio vende libri. - 书店老板卖书。", "Il libraio mi consiglia. - 书店老板给我推荐。"]),
        ("fioraio", "花商", "florist", "fjɔraio", "职业", ["Il fioraio vende fiori. - 花商卖花。", "Il fioraio è gentile. - 花商很友善。"]),
        ("panettiere", "面包师", "baker", "panɛttjɛrɛ", "职业", ["Il panettiere fa il pane. - 面包师做面包。", "Il panettiere si alza presto. - 面包师起得很早。"]),
        ("meccanico", "机械师", "mechanic", "mɛkkanko", "职业", ["Il meccanico ripara la macchina. - 机械师修理汽车。", "Il meccanico è esperto. - 机械师是专家。"]),
        ("elettricista", "电工", "electrician", "ɛlɛttritʃista", "职业", ["L'elettricista ripara le luci. - 电工修理电灯。", "L'elettricista è abile. - 电工技术娴熟。"]),
        ("idraulico", "水管工", "plumber", "idrauliko", "职业", ["L'idraulico ripara il lavandino. - 水管工修理水槽。", "L'idraulico è veloce. - 水管工动作很快。"]),
        ("muratore", "泥瓦匠", "bricklayer", "muratorɛ", "职业", ["Il muratore costruisce case. - 泥瓦匠建造房屋。", "Il muratore lavora duro. - 泥瓦匠工作辛苦。"]),
        ("pittore", "画家", "painter", "pittɔrɛ", "职业", ["Il pittore dipinge quadri. - 画家画画。", "Il pittore è famoso. - 画家很出名。"]),
        ("musicista", "音乐家", "musician", "musitʃista", "职业", ["Il musicista suona il pianoforte. - 音乐家弹钢琴。", "Il musicista è talentuoso. - 音乐家很有天赋。"]),
        ("attore", "演员", "actor", "attɔrɛ", "职业", ["L'attore recita in teatro. - 演员在剧院表演。", "L'attore è famoso. - 演员很出名。"]),
        ("attrice", "女演员", "actress", "attritʃɛ", "职业", ["L'attrice recita bene. - 女演员表演得很好。", "L'attrice è bellissima. - 女演员非常漂亮。"]),
        ("scrittore", "作家", "writer", "skrittɔrɛ", "职业", ["Lo scrittore scrive libri. - 作家写书。", "Lo scrittore è famoso. - 作家很出名。"]),
        ("giornalista", "记者", "journalist", "dʒornalista", "职业", ["Il giornalista scrive articoli. - 记者写文章。", "Il giornalista lavora per il giornale. - 记者为报社工作。"]),
    ]

    # 5. 身体部位 (20个)
    body_words = [
        ("testa", "头", "head", "tɛsta", "身体部位", ["Ho mal di testa. - 我头痛。", "La testa è importante. - 头部很重要。"]),
        ("capelli", "头发", "hair", "kapɛlli", "身体部位", ["Ho i capelli neri. - 我有黑头发。", "I capelli lunghi. - 长发。"]),
        ("occhio", "眼睛", "eye", "ɔkkjo", "身体部位", ["Ho due occhi. - 我有两只眼睛。", "L'occhio blu. - 蓝眼睛。"]),
        ("occhi", "眼睛（复数）", "eyes", "ɔkki", "身体部位", ["Gli occhi sono belli. - 眼睛很漂亮。", "Apro gli occhi. - 我睁开眼睛。"]),
        ("naso", "鼻子", "nose", "nazo", "身体部位", ["Ho il naso grande. - 我鼻子很大。", "Il naso sente gli odori. - 鼻子闻气味。"]),
        ("bocca", "嘴", "mouth", "bɔkka", "身体部位", ["Apro la bocca. - 我张开嘴。", "La bocca parla. - 嘴巴说话。"]),
        ("orecchio", "耳朵", "ear", "orɛkkjo", "身体部位", ["Ho due orecchie. - 我有两只耳朵。", "L'orecchio ascolta. - 耳朵听声音。"]),
        ("orecchie", "耳朵（复数）", "ears", "orɛkkjɛ", "身体部位", ["Le orecchie sono piccole. - 耳朵很小。", "Pulisco le orecchie. - 我清洁耳朵。"]),
        ("viso", "脸", "face", "vizo", "身体部位", ["Lavo il viso. - 我洗脸。", "Il viso è gentile. - 脸很友善。"]),
        ("fronte", "额头", "forehead", "frɔntɛ", "身体部位", ["La fronte è alta. - 额头很高。", "Sudo dalla fronte. - 我额头出汗。"]),
        ("guancia", "脸颊", "cheek", "gwantʃa", "身体部位", ["Ho le guance rosse. - 我脸颊发红。", "La guancia è morbida. - 脸颊很柔软。"]),
        ("collo", "脖子", "neck", "kollo", "身体部位", ["Il collo è lungo. - 脖子很长。", "Ho dolore al collo. - 我脖子痛。"]),
        ("spalla", "肩膀", "shoulder", "spalla", "身体部位", ["Ho due spalle. - 我有两个肩膀。", "La spalla è forte. - 肩膀很强壮。"]),
        ("braccio", "手臂", "arm", "brattʃo", "身体部位", ["Alzo il braccio. - 我举起手臂。", "Il braccio è lungo. - 手臂很长。"]),
        ("braccia", "手臂（复数）", "arms", "brattʃa", "身体部位", ["Apro le braccia. - 我张开双臂。", "Le braccia forti. - 强壮的手臂。"]),
        ("mano", "手", "hand", "mano", "身体部位", ["Lavo le mani. - 我洗手。", "La mano è calda. - 手很温暖。"]),
        ("mani", "手（复数）", "hands", "mani", "身体部位", ["Ho le mani pulite. - 我手很干净。", "Le mani lavorano. - 手在工作。"]),
        ("dito", "手指", "finger", "dito", "身体部位", ["Ho dieci dita. - 我有十根手指。", "Il dito indica. - 手指指示。"]),
        ("dita", "手指（复数）", "fingers", "dita", "身体部位", ["Le dita lunghe. - 长手指。", "Movo le dita. - 我活动手指。"]),
        ("gambe", "腿", "legs", "gambɛ", "身体部位", ["Ho due gambe. - 我有两条腿。", "Le gambe camminano. - 腿走路。"]),
        ("piede", "脚", "foot", "pjɛdɛ", "身体部位", ["Ho due piedi. - 我有两只脚。", "Il piede è grande. - 脚很大。"]),
        ("piedi", "脚（复数）", "feet", "pjɛdi", "身体部位", ["I piedi sono stanchi. - 脚很累。", "Lavo i piedi. - 我洗脚。"]),
        ("cuore", "心脏", "heart", "kuorɛ", "身体部位", ["Il cuore batte. - 心脏在跳动。", "Ho il cuore felice. - 我很高兴。"]),
        ("stomaco", "胃", "stomach", "stɔmako", "身体部位", ["Ho lo stomaco vuoto. - 我胃空空的。", "Lo stomaco digerisce. - 胃消化食物。"]),
        ("schiena", "背", "back", "skjɛna", "身体部位", ["Ho mal di schiena. - 我背痛。", "La schiena è dritta. - 背很直。"]),
    ]

    # 6. 方位和位置 (15个)
    directions_words = [
        ("sinistra", "左", "left", "sɔnistra", "方位", ["Gira a sinistra. - 向左转。", "La mano sinistra. - 左手。"]),
        ("destra", "右", "right", "dɛstra", "方位", ["Gira a destra. - 向右转。", "La mano destra. - 右手。"]),
        ("dritto", "直", "straight", "drittɔ", "方位", ["Vai dritto. - 直走。", "La strada è dritta. - 路是直的。"]),
        ("su", "上", "up", "su", "方位", ["Vado su. - 我上去。", "La casa è su. - 房子在上面。"]),
        ("giù", "下", "down", "dʒu", "方位", ["Vado giù. - 我下去。", "Il gatto scende giù. - 猫下来。"]),
        ("dentro", "里面", "inside", "dɛntro", "方位", ["Sono dentro casa. - 我在屋里。", "La chiave è dentro. - 钥匙在里面。"]),
        ("fuori", "外面", "outside", "fuɔri", "方位", ["Gioco fuori. - 我在外面玩。", "Fa freddo fuori. - 外面很冷。"]),
        ("vicino", "近", "near", "vitʃino", "方位", ["La casa è vicino. - 房子很近。", "Vicino a casa. - 靠近家。"]),
        ("lontano", "远", "far", "lontano", "方位", ["La scuola è lontano. - 学校很远。", "Vado lontano. - 我去远处。"]),
        ("qui", "这里", "here", "kwi", "方位", ["Sono qui. - 我在这里。", "Vieni qui. - 来这里。"]),
        ("qua", "这里", "here", "kwa", "方位", ["Resta qua. - 留在这里。", "Prendilo qua. - 在这里拿。"]),
        ("lì", "那里", "there", "li", "方位", ["È lì. - 它在那里。", "Vado lì. - 我去那里。"]),
        ("là", "那里", "there", "la", "方位", ["La casa è là. - 房子在那里。", "Guarda là. - 看那边。"]),
        ("fronte", "前面", "front", "frɔntɛ", "方位", ["Davanti alla casa. - 在房子前面。", "In fronte. - 在前面。"]),
        ("dietro", "后面", "behind", "djɛtro", "方位", ["Il gatto è dietro. - 猫在后面。", "Guardo dietro. - 我看后面。"]),
    ]

    # 7. 房间和家具 (20个)
    furniture_words = [
        ("tavolo", "桌子", "table", "tavolo", "家具", ["Mangio al tavolo. - 我在桌子旁吃饭。", "Il tavolo è di legno. - 桌子是木头的。"]),
        ("sedia", "椅子", "chair", "sɛdia", "家具", ["Siedo sulla sedia. - 我坐在椅子上。", "La sedia è comoda. - 椅子很舒服。"]),
        ("letto", "床", "bed", "lɛtto", "家具", ["Dormo nel letto. - 我在床上睡觉。", "Il letto è grande. - 床很大。"]),
        ("divano", "沙发", "sofa", "divano", "家具", ["Mi rilasso sul divano. - 我在沙发上放松。", "Il divano è comodo. - 沙发很舒服。"]),
        ("poltrona", "扶手椅", "armchair", "pɔltrona", "家具", ["Leggo sulla poltrona. - 我在扶手椅上阅读。", "La poltrona è comoda. - 扶手椅很舒服。"]),
        ("cucina", "厨房", "kitchen", "kuˈtʃina", "房间", ["Cucino nella cucina. - 我在厨房做饭。", "La cucina è grande. - 厨房很大。"]),
        ("camera", "房间", "room", "kamɛra", "房间", ["La mia camera è piccola. - 我的房间很小。", "Camera da letto. - 卧室。"]),
        ("salotto", "客厅", "living room", "salotto", "房间", ["Guardiamo TV in salotto. - 我们在客厅看电视。", "Il salotto è bello. - 客厅很漂亮。"]),
        ("bagno", "浴室", "bathroom", "baɲo", "房间", ["Mi lavo in bagno. - 我在浴室洗漱。", "Il bagno è piccolo. - 浴室很小。"]),
        ("ripostiglio", "储藏室", "storage room", "ripɔstildʒo", "房间", ["Mantengo le cose nel ripostiglio. - 我把东西放在储藏室。", "Il ripostiglio è pieno. - 储藏室满了。"]),
        ("terrazzo", "阳台", "terrace/balcony", "tɛrattso", "房间", ["Prendo il sole sul terrazzo. - 我在阳台晒太阳。", "Il terrazzo è grande. - 阳台很大。"]),
        ("balcone", "阳台", "balcony", "balkone", "房间", ["Le piante sono sul balcone. - 植物在阳台上。", "Il balcone fiorito. - 阳台鲜花盛开。"]),
        ("cantina", "地下室", "cellar", "kantina", "房间", ["Conservo il vino in cantina. - 我在地下室保存酒。", "La cantina è fresca. - 地下室很凉爽。"]),
        ("soffitta", "阁楼", "attic", "sɔfitta", "房间", ["Metto le cose vecchie in soffitta. - 我把旧东西放在阁楼。", "La soffitta è polverosa. - 阁楼很脏。"]),
        ("finestra", "窗户", "window", "finɛstra", "家具", ["Apro la finestra. - 我打开窗户。", "La finestra è grande. - 窗户很大。"]),
        ("porta", "门", "door", "porta", "家具", ["Apro la porta. - 我开门。", "La porta è chiusa. - 门关着。"]),
        ("specchio", "镜子", "mirror", "spɛkkjo", "家具", ["Mi guardo allo specchio. - 我照镜子。", "Lo specchio è pulito. - 镜子很干净。"]),
        ("armadio", "衣柜", "wardrobe", "armadjo", "家具", ["Metto i vestiti nell'armadio. - 我把衣服放在衣柜里。", "L'armadio è grande. - 衣柜很大。"]),
        ("libreria", "书架", "bookshelf", "librɛria", "家具", ["Metto i libri nella libreria. - 我把书放在书架上。", "La libreria è piena. - 书架满了。"]),
        ("scrivania", "书桌", "desk", "skrivania", "家具", ["Studio alla scrivania. - 我在书桌学习。", "La scrivania è ordinata. - 书桌很整洁。"]),
        ("lampada", "灯", "lamp", "lampada", "家具", ["Accendo la lampada. - 我开灯。", "La lampada è accesa. - 灯开着。"]),
    ]

    # 合并所有词汇组
    all_words = []
    for group_name, words_list in [
        ("时间词汇", time_words),
        ("地点词汇", places_words),
        ("交通词汇", transport_words),
        ("职业词汇", jobs_words),
        ("身体部位", body_words),
        ("方位词汇", directions_words),
        ("家具词汇", furniture_words),
    ]:
        print(f"\n准备生成 {group_name}: {len(words_list)} 个词汇")
        for word_data in words_list:
            current_id = next_id
            next_id = str(int(next_id) + 1)

            new_word = create_word_data(
                current_id,
                word_data[0],  # italian
                word_data[1],  # chinese
                word_data[2],  # english
                word_data[3],  # pronunciation
                word_data[4],  # category
                word_data[5]   # examples
            )
            all_words.append(new_word)

    return all_words

def main():
    """主函数"""
    print("🇮🇹 开始补充A1必需的高频词汇...")

    # 加载现有词汇
    existing_words = load_existing_words()
    if not existing_words:
        print("❌ 无法加载现有词汇数据")
        return

    print(f"✅ 已加载 {len(existing_words)} 个现有词汇")

    # 获取下一个ID
    next_id = get_next_id(existing_words)
    print(f"📝 新词汇将从ID {next_id} 开始")

    # 生成新词汇
    new_words = generate_essential_a1_words(next_id)
    print(f"\n🎯 准备添加 {len(new_words)} 个新词汇")

    # 统计各类别
    categories = {}
    for word in new_words:
        cat = word['category']
        categories[cat] = categories.get(cat, 0) + 1

    print("\n📊 新增词汇类别分布:")
    for cat, count in sorted(categories.items()):
        print(f"  {cat}: {count} 个")

    # 自动确认添加
    print(f"\n🔄 自动添加 {len(new_words)} 个新词汇...")

    # 合并词汇
    all_words = existing_words + new_words

    # 写入文件
    try:
        with open('assets/data/sample_words.json', 'w', encoding='utf-8') as f:
            json.dump(all_words, f, ensure_ascii=False, indent=2)
        print(f"\n✅ 成功添加 {len(new_words)} 个新词汇!")
        print(f"📚 词汇总数: {len(all_words)} 个")

        # 统计A1词汇
        a1_count = sum(1 for word in all_words if word['level'] == 'A1')
        print(f"🎯 A1词汇: {a1_count} 个")

        print("\n🎊 A1高频词汇补充完成!")
        print("\n📋 补充的核心主题:")
        print("  ✅ 时间表达 (数字、星期、月份)")
        print("  ✅ 城市地点和建筑物")
        print("  ✅ 交通工具和出行")
        print("  ✅ 职业和工作")
        print("  ✅ 身体部位")
        print("  ✅ 方位和位置")
        print("  ✅ 房间和家具")

        print(f"\n💡 建议: 运行 'dart run build_runner build' 更新代码生成")

    except Exception as e:
        print(f"❌ 写入文件失败: {e}")

if __name__ == "__main__":
    main()