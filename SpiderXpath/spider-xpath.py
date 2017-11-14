import scrapy
from scrapy.selector import Selector
from scrapy.http import HtmlResponse

class PlayerData(scrapy.Item):
	player = scrapy.Field()
	champion = scrapy.Field()
	games = scrapy.Field()
	win = scrapy.Field()
	lose = scrapy.Field()
	kda = scrapy.Field()



class ScrapyXPathSpider(scrapy.Spider):
	name = "spider-xpath"
	allowed_domains = ['gamepedia.com']
	start_urls = ['http://lol.gamepedia.com/Khan/Champion_Statistics',
			'http://lol.gamepedia.com/Cuzz/Champion_Statistics',
			'http://lol.gamepedia.com/Bdd/Champion_Statistics',
			'http://lol.gamepedia.com/PraY/Champion_Statistics',
			'http://lol.gamepedia.com/GorillA/Champion_Statistics',
			'http://lol.gamepedia.com/Rascal/Champion_Statistics',

			'http://lol.gamepedia.com/Mouse/Champion_Statistics',
			'http://lol.gamepedia.com/Clearlove7/Champion_Statistics',
			'http://lol.gamepedia.com/Scout/Champion_Statistics',
			'http://lol.gamepedia.com/iBoy/Champion_Statistics',
			'http://lol.gamepedia.com/Meiko/Champion_Statistics',
			'http://lol.gamepedia.com/Audi/Champion_Statistics',

			'http://lol.gamepedia.com/Expect/Champion_Statistics',
			'http://lol.gamepedia.com/Trick/Champion_Statistics',
			'http://lol.gamepedia.com/Perkz/Champion_Statistics',
			'http://lol.gamepedia.com/Zven/Champion_Statistics',
			'http://lol.gamepedia.com/Mithy/Champion_Statistics',
			'http://lol.gamepedia.com/Hoang/Champion_Statistics',

			'http://lol.gamepedia.com/MMD/Champion_Statistics',
			'http://lol.gamepedia.com/Karsa/Champion_Statistics',
			'http://lol.gamepedia.com/Maple/Champion_Statistics',
			'http://lol.gamepedia.com/Betty/Champion_Statistics',
			'http://lol.gamepedia.com/SwordArt/Champion_Statistics',
			'http://lol.gamepedia.com/Cyo/Champion_Statistics',

			'http://lol.gamepedia.com/Huni/Champion_Statistics',
			'http://lol.gamepedia.com/Peanut/Champion_Statistics',
			'http://lol.gamepedia.com/Faker/Champion_Statistics',
			'http://lol.gamepedia.com/Bang/Champion_Statistics',
			'http://lol.gamepedia.com/Wolf/Champion_Statistics',
			'http://lol.gamepedia.com/Blank/Champion_Statistics',

			'http://lol.gamepedia.com/CuVee/Champion_Statistics',
			'http://lol.gamepedia.com/Ambition/Champion_Statistics',
			'http://lol.gamepedia.com/Crown/Champion_Statistics',
			'http://lol.gamepedia.com/Ruler/Champion_Statistics',
			'http://lol.gamepedia.com/CoreJJ/Champion_Statistics',
			'http://lol.gamepedia.com/Haru/Champion_Statistics',

			'http://lol.gamepedia.com/LetMe/Champion_Statistics',
			'http://lol.gamepedia.com/mlxg/Champion_Statistics',
			'http://lol.gamepedia.com/Xiaohu/Champion_Statistics',
			'http://lol.gamepedia.com/Uzi/Champion_Statistics',
			'http://lol.gamepedia.com/Ming/Champion_Statistics',
			'http://lol.gamepedia.com/Y1HAN/Champion_Statistics',

			'http://lol.gamepedia.com/Hauntzer/Champion_Statistics',
			'http://lol.gamepedia.com/Svenskeren/Champion_Statistics',
			'http://lol.gamepedia.com/Bjergsen/Champion_Statistics',
			'http://lol.gamepedia.com/Doublelift/Champion_Statistics',
			'http://lol.gamepedia.com/Biofrost/Champion_Statistics',
			'http://lol.gamepedia.com/MrRalleZ/Champion_Statistics',

			'http://lol.gamepedia.com/Flame/Champion_Statistics',
			'http://lol.gamepedia.com/Xmithie/Champion_Statistics',
			'http://lol.gamepedia.com/Pobelter/Champion_Statistics',
			'http://lol.gamepedia.com/Cody_Sun/Champion_Statistics',
			'http://lol.gamepedia.com/Olleh/Champion_Statistics',
			'http://lol.gamepedia.com/AnDa/Champion_Statistics',

			'http://lol.gamepedia.com/Alphari/Champion_Statistics',
			'http://lol.gamepedia.com/Maxlore/Champion_Statistics',
			'http://lol.gamepedia.com/PowerOfEvil/Champion_Statistics',
			'http://lol.gamepedia.com/Hans_Sama/Champion_Statistics',
			'http://lol.gamepedia.com/IgNar/Champion_Statistics',
			'http://lol.gamepedia.com/Hiva/Champion_Statistics',

			'http://lol.gamepedia.com/Ziv/Champion_Statistics',
			'http://lol.gamepedia.com/Mountain/Champion_Statistics',
			'http://lol.gamepedia.com/Westdoor/Champion_Statistics',
			'http://lol.gamepedia.com/AN/Champion_Statistics',
			'http://lol.gamepedia.com/Albis/Champion_Statistics',
			'http://lol.gamepedia.com/Chawy/Champion_Statistics',

			'http://lol.gamepedia.com/Archie/Champion_Statistics',
			'http://lol.gamepedia.com/Levi/Champion_Statistics',
			'http://lol.gamepedia.com/Optimus/Champion_Statistics',
			'http://lol.gamepedia.com/NoWay/Champion_Statistics',
			'http://lol.gamepedia.com/Sya/Champion_Statistics',
			'http://lol.gamepedia.com/Nevan/Champion_Statistics',

			'http://lol.gamepedia.com/Impact/Champion_Statistics',
			'http://lol.gamepedia.com/Contractz/Champion_Statistics',
			'http://lol.gamepedia.com/Jensen/Champion_Statistics',
			'http://lol.gamepedia.com/Sneaky/Champion_Statistics',
			'http://lol.gamepedia.com/Smoothie/Champion_Statistics',
			'http://lol.gamepedia.com/Ray/Champion_Statistics',

			'http://lol.gamepedia.com/sOAZ/Champion_Statistics',
			'http://lol.gamepedia.com/Broxah/Champion_Statistics',
			'http://lol.gamepedia.com/Caps/Champion_Statistics',
			'http://lol.gamepedia.com/Rekkles/Champion_Statistics',
			'http://lol.gamepedia.com/Jesiz/Champion_Statistics',
			'http://lol.gamepedia.com/Special/Champion_Statistics',

			'http://lol.gamepedia.com/Thaldrin/Champion_Statistics',
			'http://lol.gamepedia.com/Crash/Champion_Statistics',
			'http://lol.gamepedia.com/Frozen/Champion_Statistics',
			'http://lol.gamepedia.com/padden/Champion_Statistics',
			'http://lol.gamepedia.com/Japone/Champion_Statistics',
			'http://lol.gamepedia.com/WaenA/Champion_Statistics',

			'http://lol.gamepedia.com/957/Champion_Statistics',
			'http://lol.gamepedia.com/Condi/Champion_Statistics',
			'http://lol.gamepedia.com/xiye/Champion_Statistics',
			'http://lol.gamepedia.com/Mystic/Champion_Statistics',
			'http://lol.gamepedia.com/Zero/Champion_Statistics',
			'http://lol.gamepedia.com/Ben/Champion_Statistics',

			'http://lol.gamepedia.com/Riris/Champion_Statistics',
			'http://lol.gamepedia.com/GodKwai/Champion_Statistics',
			'http://lol.gamepedia.com/M1ssion/Champion_Statistics',
			'http://lol.gamepedia.com/Unified/Champion_Statistics',
			'http://lol.gamepedia.com/Kaiwing/Champion_Statistics',
			'http://lol.gamepedia.com/Gemini/Champion_Statistics',

			'http://lol.gamepedia.com/VVvert/Champion_Statistics',
			'http://lol.gamepedia.com/4LaN/Champion_Statistics',
			'http://lol.gamepedia.com/Brucer/Champion_Statistics',
			'http://lol.gamepedia.com/Absolut/Champion_Statistics',
			'http://lol.gamepedia.com/RedBert/Champion_Statistics',
			'http://lol.gamepedia.com/Marf/Champion_Statistics',

			'http://lol.gamepedia.com/Evi/Champion_Statistics',
			'http://lol.gamepedia.com/Tussle/Champion_Statistics',
			'http://lol.gamepedia.com/Ramune/Champion_Statistics',
			'http://lol.gamepedia.com/YutoriMoyasi/Champion_Statistics',
			'http://lol.gamepedia.com/Dara/Champion_Statistics',

			'http://lol.gamepedia.com/Chippys/Champion_Statistics',
			'http://lol.gamepedia.com/Shernfire/Champion_Statistics',
			'http://lol.gamepedia.com/Phantiks/Champion_Statistics',
			'http://lol.gamepedia.com/k1ng/Champion_Statistics',
			'http://lol.gamepedia.com/Destiny/Champion_Statistics',
			'http://lol.gamepedia.com/Rippii/Champion_Statistics',

			'http://lol.gamepedia.com/Ren/Champion_Statistics',
			'http://lol.gamepedia.com/Venus/Champion_Statistics',
			'http://lol.gamepedia.com/Naul/Champion_Statistics',
			'http://lol.gamepedia.com/BigKoro/Champion_Statistics',
			'http://lol.gamepedia.com/Palette/Champion_Statistics',
			'http://lol.gamepedia.com/NhocTy/Champion_Statistics',

			'http://lol.gamepedia.com/PvPStejos/Champion_Statistics',
			'http://lol.gamepedia.com/Diamondprox/Champion_Statistics',
			'http://lol.gamepedia.com/Kira/Champion_Statistics',
			'http://lol.gamepedia.com/Blasting/Champion_Statistics',
			'http://lol.gamepedia.com/EDward/Champion_Statistics',
			'http://lol.gamepedia.com/Tauren/Champion_Statistics',

			'http://lol.gamepedia.com/MANTARRAYA/Champion_Statistics',
			'http://lol.gamepedia.com/Tierwulf/Champion_Statistics',
			'http://lol.gamepedia.com/Plugo/Champion_Statistics',
			'http://lol.gamepedia.com/Fix/Champion_Statistics',
			'http://lol.gamepedia.com/Slow/Champion_Statistics',
			'http://lol.gamepedia.com/Focho/Champion_Statistics',

			'http://lol.gamepedia.com/Jirall/Champion_Statistics',
			'http://lol.gamepedia.com/Oddie/Champion_Statistics',
			'http://lol.gamepedia.com/Seiya/Champion_Statistics',
			'http://lol.gamepedia.com/WhiteLotus/Champion_Statistics',
			'http://lol.gamepedia.com/Genthix/Champion_Statistics',
			'http://lol.gamepedia.com/MarioMe/Champion_Statistics',

			]


	def parse(self, response):

		for row in response.xpath('//*[@id="mw-content-text"]/table[3]/tr'):
			
			yield {

			'player': response.xpath('//*[@id="contentSub"]/span/a/text()').extract_first(),
			'champion': row.xpath('./td[1]/a/span[2]/text()').extract(),
			'games': row.xpath('./td[2]/text()').extract(),
			'win': row.xpath('./td[3]/text()').extract(),
			'lose': row.xpath('./td[4]/text()').extract(),
			'kda': row.xpath('./td[9]/text()').extract()

			}


