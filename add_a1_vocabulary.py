#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量添加A1基础词汇
重点类别：颜色、身体部位、衣物、情绪、天气、方位、量词
"""

import json
from datetime import datetime

# 读取现有词汇
with open('assets/data/sample_words.json', 'r', encoding='utf-8') as f:
    words = json.load(f)

# 找到最大ID
max_id = max([int(w['id']) for w in words])
print(f"当前最大ID: {max_id}")
print(f"当前A1词汇数: {len([w for w in words if w.get('level') == 'A1'])}")

# 新词汇列表
new_words = []
current_id = max_id + 1

# ========== 1. 颜色 (15词) ==========
colors = [
    ("rosso", "红色", "red", "ˈrosso", ["La mia macchina è rossa. - 我的车是红色的。", "Mi piace il vestito rosso. - 我喜欢红色的裙子。"]),
    ("blu", "蓝色", "blue", "blu", ["Il cielo è blu. - 天空是蓝色的。", "Ho gli occhi blu. - 我有蓝色的眼睛。"]),
    ("verde", "绿色", "green", "ˈverde", ["L'erba è verde. - 草是绿色的。", "Mangio l'insalata verde. - 我吃绿色的沙拉。"]),
    ("giallo", "黄色", "yellow", "ˈdʒallo", ["Il sole è giallo. - 太阳是黄色的。", "I limoni sono gialli. - 柠檬是黄色的。"]),
    ("nero", "黑色", "black", "ˈnero", ["Il gatto è nero. - 猫是黑色的。", "Porto scarpe nere. - 我穿黑色的鞋子。"]),
    ("bianco", "白色", "white", "ˈbjanko", ["La neve è bianca. - 雪是白色的。", "Bevo il latte bianco. - 我喝白色的牛奶。"]),
    ("arancione", "橙色", "orange", "aranˈtʃone", ["L'arancia è arancione. - 橙子是橙色的。", "Il tramonto è arancione. - 日落是橙色的。"]),
    ("rosa", "粉色", "pink", "ˈroza", ["Il fiore è rosa. - 花是粉色的。", "Le bambine amano il rosa. - 小女孩喜欢粉色。"]),
    ("grigio", "灰色", "gray", "ˈɡridʒo", ["Il cielo è grigio oggi. - 今天天空是灰色的。", "Ho un cappotto grigio. - 我有一件灰色的外套。"]),
    ("marrone", "棕色", "brown", "marˈrone", ["L'orso è marrone. - 熊是棕色的。", "I miei capelli sono marroni. - 我的头发是棕色的。"]),
    ("viola", "紫色", "purple", "ˈvjola", ["L'uva è viola. - 葡萄是紫色的。", "Mi piace il colore viola. - 我喜欢紫色。"]),
    ("azzurro", "天蓝色", "light blue", "atˈtsurro", ["Il mare è azzurro. - 大海是天蓝色的。", "La maglia azzurra è bella. - 天蓝色的衬衫很漂亮。"]),
    ("colorato", "彩色的", "colorful", "koloˈrato", ["Il quadro è molto colorato. - 画很彩色。", "I palloncini colorati sono belli. - 彩色的气球很漂亮。"]),
    ("chiaro", "浅色的", "light", "ˈkjaro", ["Preferisco i colori chiari. - 我更喜欢浅色。", "La stanza è chiara. - 房间是明亮的。"]),
    ("scuro", "深色的", "dark", "ˈskuro", ["Fuori è scuro. - 外面很暗。", "Porto vestiti scuri. - 我穿深色的衣服。"]),
]

for italian, chinese, english, pronunciation, examples in colors:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "颜色",
        "level": "A1",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# ========== 2. 身体部位 (25词) ==========
body_parts = [
    ("testa", "头", "head", "ˈtesta", ["Mi fa male la testa. - 我头疼。", "Ho una grande testa. - 我有一个大头。"]),
    ("occhio", "眼睛", "eye", "ˈɔkkjo", ["Ho due occhi. - 我有两只眼睛。", "I miei occhi sono marroni. - 我的眼睛是棕色的。"]),
    ("occhi", "眼睛(复数)", "eyes", "ˈɔkki", ["I suoi occhi sono azzurri. - 他的眼睛是蓝色的。", "Chiudi gli occhi! - 闭上眼睛!"]),
    ("orecchio", "耳朵", "ear", "oˈrekkjo", ["Ho mal d'orecchio. - 我耳朵疼。", "Pulisco le orecchie. - 我清洁耳朵。"]),
    ("naso", "鼻子", "nose", "ˈnazo", ["Ho il naso lungo. - 我有长鼻子。", "Mi fa male il naso. - 我鼻子疼。"]),
    ("bocca", "嘴巴", "mouth", "ˈbokka", ["Apri la bocca! - 张开嘴!", "Ho la bocca asciutta. - 我嘴巴干。"]),
    ("dente", "牙齿", "tooth", "ˈdɛnte", ["Ho mal di denti. - 我牙疼。", "Mi lavo i denti. - 我刷牙。"]),
    ("collo", "脖子", "neck", "ˈkɔllo", ["Ho il collo lungo. - 我有长脖子。", "Mi fa male il collo. - 我脖子疼。"]),
    ("spalla", "肩膀", "shoulder", "ˈspalla", ["Ho dolore alla spalla. - 我肩膀疼。", "Porto la borsa sulla spalla. - 我把包背在肩上。"]),
    ("braccio", "手臂", "arm", "ˈbrattʃo", ["Ho due braccia. - 我有两条手臂。", "Mi fa male il braccio. - 我手臂疼。"]),
    ("mano", "手", "hand", "ˈmano", ["Ho le mani fredde. - 我手冷。", "Dammi la mano! - 给我你的手!"]),
    ("dito", "手指", "finger", "ˈdito", ["Ho cinque dita. - 我有五根手指。", "Mi fa male il dito. - 我手指疼。"]),
    ("petto", "胸部", "chest", "ˈpetto", ["Ho dolore al petto. - 我胸口疼。", "Il cuore è nel petto. - 心脏在胸腔里。"]),
    ("stomaco", "胃/肚子", "stomach", "ˈstomako", ["Mi fa male lo stomaco. - 我胃疼。", "Ho lo stomaco vuoto. - 我肚子空。"]),
    ("pancia", "肚子", "belly", "ˈpantʃa", ["Ho la pancia piena. - 我肚子饱了。", "Mi fa male la pancia. - 我肚子疼。"]),
    ("schiena", "背部", "back", "ˈskjena", ["Mi fa male la schiena. - 我背疼。", "Ho la schiena dritta. - 我背挺直。"]),
    ("gamba", "腿", "leg", "ˈɡamba", ["Ho due gambe. - 我有两条腿。", "Le mie gambe sono lunghe. - 我的腿很长。"]),
    ("ginocchio", "膝盖", "knee", "dʒiˈnɔkkjo", ["Mi fa male il ginocchio. - 我膝盖疼。", "Mi sono fatto male al ginocchio. - 我膝盖受伤了。"]),
    ("piede", "脚", "foot", "ˈpjɛde", ["Ho i piedi stanchi. - 我脚累了。", "Mi fanno male i piedi. - 我脚疼。"]),
    ("faccia", "脸", "face", "ˈfattʃa", ["Ho la faccia rossa. - 我脸红了。", "Mi lavo la faccia. - 我洗脸。"]),
    ("capelli", "头发", "hair", "kaˈpelli", ["Ho i capelli lunghi. - 我有长头发。", "I miei capelli sono neri. - 我的头发是黑色的。"]),
    ("barba", "胡子", "beard", "ˈbarba", ["Lui ha la barba. - 他有胡子。", "Mi faccio la barba. - 我刮胡子。"]),
    ("cuore", "心脏/心", "heart", "ˈkwore", ["Il mio cuore batte forte. - 我的心跳得很快。", "Ti amo con tutto il cuore. - 我全心全意爱你。"]),
    ("pelle", "皮肤", "skin", "ˈpelle", ["Ho la pelle chiara. - 我皮肤白。", "La mia pelle è secca. - 我的皮肤很干。"]),
    ("sangue", "血", "blood", "ˈsangwe", ["Ho paura del sangue. - 我怕血。", "Dono il sangue. - 我献血。"]),
]

for italian, chinese, english, pronunciation, examples in body_parts:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "身体部位",
        "level": "A1",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# ========== 3. 衣物 (20词) ==========
clothing = [
    ("vestito", "连衣裙/衣服", "dress/clothes", "vesˈtito", ["Il vestito è bello. - 裙子很漂亮。", "Compro un vestito nuovo. - 我买一件新衣服。"]),
    ("maglietta", "T恤", "t-shirt", "maʎˈʎetta", ["Porto una maglietta bianca. - 我穿一件白色T恤。", "La maglietta è comoda. - T恤很舒服。"]),
    ("camicia", "衬衫", "shirt", "kaˈmitʃa", ["Porto una camicia blu. - 我穿一件蓝色衬衫。", "La camicia è stirata. - 衬衫熨好了。"]),
    ("pantaloni", "裤子", "pants", "pantaˈloni", ["I pantaloni sono lunghi. - 裤子很长。", "Compro pantaloni neri. - 我买黑色裤子。"]),
    ("gonna", "裙子", "skirt", "ˈɡonna", ["La gonna è corta. - 裙子很短。", "Mi piace la gonna rossa. - 我喜欢红色裙子。"]),
    ("giacca", "夹克", "jacket", "ˈdʒakka", ["Porto la giacca. - 我穿夹克。", "La giacca è calda. - 夹克很暖和。"]),
    ("cappotto", "大衣", "coat", "kapˈpɔtto", ["In inverno porto il cappotto. - 冬天我穿大衣。", "Il cappotto è pesante. - 大衣很厚重。"]),
    ("scarpe", "鞋子", "shoes", "ˈskarpe", ["Le scarpe sono comode. - 鞋子很舒服。", "Compro scarpe nuove. - 我买新鞋子。"]),
    ("stivali", "靴子", "boots", "stiˈvali", ["Porto gli stivali in inverno. - 冬天我穿靴子。", "Gli stivali sono alti. - 靴子很高。"]),
    ("calze", "袜子", "socks", "ˈkaltse", ["Le calze sono calde. - 袜子很暖和。", "Porto calze bianche. - 我穿白色袜子。"]),
    ("cappello", "帽子", "hat", "kapˈpello", ["Porto un cappello. - 我戴帽子。", "Il cappello è grande. - 帽子很大。"]),
    ("berretto", "便帽", "cap", "berˈretto", ["Il berretto è rosso. - 便帽是红色的。", "Porto il berretto in inverno. - 冬天我戴便帽。"]),
    ("occhiali", "眼镜", "glasses", "okˈkjali", ["Porto gli occhiali. - 我戴眼镜。", "I miei occhiali sono rotti. - 我的眼镜坏了。"]),
    ("orologio", "手表", "watch", "oroˈlodʒo", ["Il mio orologio è bello. - 我的手表很漂亮。", "Guardo l'orologio. - 我看手表。"]),
    ("borsa", "包/手提包", "bag", "ˈborsa", ["La borsa è grande. - 包很大。", "Compro una borsa nuova. - 我买一个新包。"]),
    ("zaino", "背包", "backpack", "dzaˈino", ["Lo zaino è pesante. - 背包很重。", "Porto lo zaino a scuola. - 我背书包去学校。"]),
    ("cintura", "腰带", "belt", "tʃinˈtura", ["La cintura è di cuoio. - 腰带是皮革的。", "Porto una cintura nera. - 我系黑色腰带。"]),
    ("guanti", "手套", "gloves", "ˈɡwanti", ["I guanti sono caldi. - 手套很暖和。", "Porto i guanti in inverno. - 冬天我戴手套。"]),
    ("sciarpa", "围巾", "scarf", "ˈʃarfa", ["La sciarpa è lunga. - 围巾很长。", "Porto la sciarpa rossa. - 我围红色围巾。"]),
    ("costume", "泳衣", "swimsuit", "kosˈtume", ["Il costume è nuovo. - 泳衣是新的。", "Compro un costume da bagno. - 我买一件泳衣。"]),
]

for italian, chinese, english, pronunciation, examples in clothing:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "衣物",
        "level": "A1",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# ========== 4. 情绪 (15词) ==========
emotions = [
    ("felice", "快乐的", "happy", "feˈlitʃe", ["Sono molto felice! - 我很快乐!", "Lei è felice oggi. - 她今天很开心。"]),
    ("triste", "悲伤的", "sad", "ˈtriste", ["Sono triste. - 我很难过。", "Perché sei triste? - 你为什么难过?"]),
    ("contento", "满意的", "content", "konˈtento", ["Sono contento del risultato. - 我对结果很满意。", "Lei è contenta. - 她很满意。"]),
    ("arrabbiato", "生气的", "angry", "arraˈbjato", ["Sono arrabbiato! - 我生气了!", "Lui è arrabbiato con me. - 他对我生气。"]),
    ("preoccupato", "担心的", "worried", "preokˈkupato", ["Sono preoccupato per te. - 我为你担心。", "Lei è preoccupata. - 她很担心。"]),
    ("stanco", "累的", "tired", "ˈstanko", ["Sono molto stanco. - 我很累。", "Lei è stanca. - 她累了。"]),
    ("annoiato", "无聊的", "bored", "annoˈjato", ["Sono annoiato. - 我很无聊。", "Il film è annoiante. - 电影很无聊。"]),
    ("emozionato", "激动的", "excited", "emotsjoˈnato", ["Sono emozionato! - 我很激动!", "Siamo emozionati per il viaggio. - 我们对旅行很兴奋。"]),
    ("sorpreso", "惊讶的", "surprised", "sorˈprezo", ["Sono sorpreso! - 我很惊讶!", "Lei è sorpresa dalla notizia. - 她对消息感到惊讶。"]),
    ("nervoso", "紧张的", "nervous", "nerˈvozo", ["Sono nervoso prima dell'esame. - 考试前我很紧张。", "Lei è nervosa. - 她很紧张。"]),
    ("calmo", "平静的", "calm", "ˈkalmo", ["Sono calmo adesso. - 我现在很平静。", "Rimani calmo! - 保持冷静!"]),
    ("paura", "害怕/恐惧", "fear", "paˈura", ["Ho paura del buio. - 我怕黑。", "Non avere paura! - 别害怕!"]),
    ("spaventato", "害怕的", "scared", "spavenˈtato", ["Sono spaventato! - 我害怕!", "Il bambino è spaventato. - 孩子害怕了。"]),
    ("orgoglioso", "骄傲的", "proud", "orɡoʎˈʎozo", ["Sono orgoglioso di te. - 我为你骄傲。", "Lei è orgogliosa. - 她很自豪。"]),
    ("geloso", "嫉妒的", "jealous", "dʒeˈlozo", ["Sono geloso. - 我嫉妒。", "Lui è geloso di lei. - 他嫉妒她。"]),
]

for italian, chinese, english, pronunciation, examples in emotions:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "情绪",
        "level": "A1",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# ========== 5. 天气 (15词) ==========
weather = [
    ("tempo", "天气", "weather", "ˈtempo", ["Che tempo fa? - 天气怎么样?", "Il tempo è bello oggi. - 今天天气好。"]),
    ("sole", "太阳", "sun", "ˈsole", ["C'è il sole oggi. - 今天有太阳。", "Il sole splende. - 太阳在闪耀。"]),
    ("pioggia", "雨", "rain", "ˈpjɔddʒa", ["C'è pioggia oggi. - 今天下雨。", "Mi piace la pioggia. - 我喜欢雨。"]),
    ("neve", "雪", "snow", "ˈneve", ["C'è neve in inverno. - 冬天下雪。", "La neve è bianca. - 雪是白色的。"]),
    ("vento", "风", "wind", "ˈvento", ["C'è vento oggi. - 今天有风。", "Il vento è forte. - 风很大。"]),
    ("nuvola", "云", "cloud", "ˈnuvola", ["Ci sono nuvole nel cielo. - 天空有云。", "Le nuvole sono bianche. - 云是白色的。"]),
    ("caldo", "热的", "hot", "ˈkaldo", ["Fa caldo oggi. - 今天很热。", "L'estate è calda. - 夏天很热。"]),
    ("freddo", "冷的", "cold", "ˈfreddo", ["Fa freddo oggi. - 今天很冷。", "L'inverno è freddo. - 冬天很冷。"]),
    ("fresco", "凉爽的", "cool", "ˈfresko", ["Fa fresco stasera. - 今晚很凉爽。", "L'aria è fresca. - 空气清新。"]),
    ("bello", "好的(天气)", "nice", "ˈbɛllo", ["Fa bel tempo. - 天气好。", "Oggi è una bella giornata. - 今天是美好的一天。"]),
    ("brutto", "坏的(天气)", "bad", "ˈbrutto", ["Fa brutto tempo. - 天气不好。", "Oggi il tempo è brutto. - 今天天气糟糕。"]),
    ("temporale", "暴风雨", "storm", "tempoˈrale", ["C'è un temporale. - 有暴风雨。", "Il temporale è forte. - 暴风雨很强。"]),
    ("nebbia", "雾", "fog", "ˈnebbja", ["C'è nebbia stamattina. - 今早有雾。", "La nebbia è fitta. - 雾很浓。"]),
    ("temperatura", "温度", "temperature", "temperatˈtura", ["La temperatura è alta. - 温度高。", "Qual è la temperatura? - 温度是多少?"]),
    ("stagione", "季节", "season", "stadʒˈʒone", ["La mia stagione preferita è l'estate. - 我最喜欢的季节是夏天。", "Ci sono quattro stagioni. - 有四个季节。"]),
]

for italian, chinese, english, pronunciation, examples in weather:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "天气",
        "level": "A1",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# ========== 6. 方位词 (10词) ==========
directions = [
    ("sopra", "在...上面", "above", "ˈsopra", ["Il libro è sopra il tavolo. - 书在桌子上。", "L'aereo vola sopra le nuvole. - 飞机在云上飞。"]),
    ("sotto", "在...下面", "under", "ˈsotto", ["Il gatto è sotto il letto. - 猫在床下。", "Metto le scarpe sotto la sedia. - 我把鞋放在椅子下。"]),
    ("dentro", "在...里面", "inside", "ˈdentro", ["Sono dentro casa. - 我在家里。", "Il gatto è dentro la scatola. - 猫在盒子里。"]),
    ("fuori", "在...外面", "outside", "ˈfwɔri", ["Sono fuori casa. - 我在外面。", "Il cane è fuori. - 狗在外面。"]),
    ("vicino", "靠近/附近", "near", "viˈtʃino", ["Abito vicino alla scuola. - 我住在学校附近。", "La farmacia è vicino. - 药店很近。"]),
    ("lontano", "远的", "far", "lonˈtano", ["La stazione è lontana. - 车站很远。", "Abito lontano da qui. - 我住得离这里远。"]),
    ("davanti", "在...前面", "in front", "daˈvanti", ["Sono davanti alla porta. - 我在门前。", "La macchina è davanti a casa. - 车在房子前面。"]),
    ("dietro", "在...后面", "behind", "ˈdjɛtro", ["Il giardino è dietro la casa. - 花园在房子后面。", "Sono dietro di te. - 我在你后面。"]),
    ("destra", "右边", "right", "ˈdɛstra", ["Gira a destra. - 向右转。", "La banca è a destra. - 银行在右边。"]),
    ("sinistra", "左边", "left", "siˈnistra", ["Gira a sinistra. - 向左转。", "Il negozio è a sinistra. - 商店在左边。"]),
]

for italian, chinese, english, pronunciation, examples in directions:
    new_words.append({
        "id": str(current_id),
        "italian": italian,
        "chinese": chinese,
        "english": english,
        "pronunciation": pronunciation,
        "category": "方位词",
        "level": "A1",
        "createdAt": datetime.now().isoformat() + "Z",
        "examples": examples
    })
    current_id += 1

# 添加新词汇到列表
words.extend(new_words)

# 写回文件
with open('assets/data/sample_words.json', 'w', encoding='utf-8') as f:
    json.dump(words, f, ensure_ascii=False, indent=2)

print(f"\n✅ 成功添加 {len(new_words)} 个A1词汇!")
print(f"新的总词汇数: {len(words)}")
print(f"新的A1词汇数: {len([w for w in words if w.get('level') == 'A1'])}")
print(f"\n添加的类别统计:")
print(f"  - 颜色: 15词")
print(f"  - 身体部位: 25词")
print(f"  - 衣物: 20词")
print(f"  - 情绪: 15词")
print(f"  - 天气: 15词")
print(f"  - 方位词: 10词")
print(f"  总计: 100词")
