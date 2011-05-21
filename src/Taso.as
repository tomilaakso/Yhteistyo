package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.system.System;
	
	import org.flixel.*;
	
	public class Taso extends FlxState
	{
		
		[Embed(source = 'maa.png')]private static var maa:Class;
		
		[Embed(source = 'taso1.png')] private static var taso1Embed:Class;
		[Embed(source = 'taso2.png')] private static var taso2Embed:Class;
		[Embed(source = 'taso3.png')] private static var taso3Embed:Class;
		[Embed(source = 'taso4.png')] private static var taso4Embed:Class;
		[Embed(source = 'taso5.png')] private static var taso5Embed:Class;
		[Embed(source = 'taso6.png')] private static var taso6Embed:Class;
		[Embed(source = 'taso7.png')] private static var taso7Embed:Class;
		[Embed(source = 'taso8.png')] private static var taso8Embed:Class;
		[Embed(source = 'taso9.png')] private static var taso9Embed:Class;
		[Embed(source = 'loppu.png')] private static var loppuEmbed:Class;
		
		[Embed(source="ukko.png")] private static var ukko:Class;
		[Embed(source="apu.png")] private static var apu:Class;
		
		[Embed(source="ovi.png")] private static var ovi:Class;
		
		private const TILE_WIDTH:uint = 16;
		private const TILE_HEIGHT:uint = 16;
		
		private var kartta:FlxTilemap;
		
		private var pelaajat:Array;
		
		private var vuorollinen:int;
		
		private var maali:FlxSprite;
		
		private var pelitaso:BitmapData;
		private var tasolla:int;
		
		private var teksti:FlxText;
		private var viesti:String;
		
		private var ekaKerta:Boolean;
		
		public function Taso()
		{
			FlxG.framerate = 50;
			FlxG.flashFramerate = 50;
			
			pelaajat = new Array();
			
			ekaKerta = true;
			
			luoKartta(1);
		}		
		
		private function luoPelaaja(vuoro:int, xKoord:int, yKoord:int):void
		{
			pelaajat[vuoro] = new FlxSprite(xKoord, yKoord);
			if (vuoro == 0)
			{
				pelaajat[vuoro].loadGraphic(ukko, true, true, 16);
			}
			else 
			{
				pelaajat[vuoro].loadGraphic(apu, true, true, 16);
			}
			
			pelaajat[vuoro].width = 14;
			pelaajat[vuoro].height = 14;
			pelaajat[vuoro].offset.x = 1;
			pelaajat[vuoro].offset.y = 1;
			
			pelaajat[vuoro].drag.x = 640;
			pelaajat[vuoro].acceleration.y = 420;
			pelaajat[vuoro].maxVelocity.x = 80;
			pelaajat[vuoro].maxVelocity.y = 200;
			
			pelaajat[vuoro].addAnimation("paikka", [0]);
			pelaajat[vuoro].addAnimation("liike", [1, 2, 3, 0], 12);
			pelaajat[vuoro].addAnimation("hyppy", [4]);
			
			add(pelaajat[vuoro]);
		}
		
		override public function update():void
		{
			for (var h:int; h<pelaajat.length; h++) 
			{
				if (pelaajat[h].x < 0)
					pelaajat[h].x = 0;
				if (pelaajat[h].x > kartta.width - 16)
					pelaajat[h].x = kartta.width - 16;
				if (pelaajat[h].y > kartta.height - 16)
					restart();
			}
			for (var i:int=0; i<pelaajat.length; i++)
			{
				FlxG.collide(pelaajat[i], kartta);
				FlxG.collide(pelaajat[i], maali, paastyMaaliin);
				paivita(i);
				for (var j:int=0; j<pelaajat.length; j++)
				{
					if (i != j)
					{
						FlxG.collide(pelaajat[i], pelaajat[j], tormaysKutsu);
					}
				}
			}
			
			for (var k:int=pelaajat.length-1; k>=0; k--)
			{
				FlxG.collide(pelaajat[k], kartta);
				paivita(k);
				for (var l:int=pelaajat.length-1; l>=0; l--)
				{
					if (k != l)
					{
						FlxG.collide(pelaajat[k], pelaajat[l], tormaysKutsu);
					}
				}
			}
			vaihdaVuoroa();
			super.update();
		}
		
		private function paivita(vuorossa:int):void
		{
			wrap(pelaajat[vuorossa]);
			
			pelaajat[vuorossa].acceleration.x = 0;
			if (vuorossa == vuorollinen)
			{
				if(FlxG.keys.LEFT)
				{
					pelaajat[vuorossa].facing = FlxObject.LEFT;
					pelaajat[vuorossa].acceleration.x -= pelaajat[vuorossa].drag.x;
				}
				else if(FlxG.keys.RIGHT)
				{
					pelaajat[vuorossa].facing = FlxObject.RIGHT;
					pelaajat[vuorossa].acceleration.x += pelaajat[vuorossa].drag.x;
				}
				if(FlxG.keys.justPressed("UP") && pelaajat[vuorossa].velocity.y == 0)
				{
					pelaajat[vuorossa].y -= 1;
					pelaajat[vuorossa].velocity.y = -200;
				}
			}
			
			if(pelaajat[vuorossa].velocity.y != 0)
			{
				pelaajat[vuorossa].play("hyppy");
			}
			else if(pelaajat[vuorossa].velocity.x == 0)
			{
				pelaajat[vuorossa].play("paikka");
			}
			else
			{
				pelaajat[vuorossa].play("liike");
			}
		}
		
		public function tormaysKutsu(tormaa:FlxObject, kolahtaa:FlxObject):void
		{
			if (tormaa.y > kolahtaa.y + 10)
			{
				// tormaa on alla
				kolahtaa.velocity.y = 0;
				if (tormaa.velocity.y < 0)
				{
					kolahtaa.y -= 1;
					kolahtaa.velocity.y = tormaa.velocity.y - 200;
				}
			}
			else if (kolahtaa.y > tormaa.y + 10)
			{
				// kolahtaa on alla
				tormaa.velocity.y = 0;
				if (kolahtaa.velocity.y < 0)
				{
					tormaa.y -= 1;
					tormaa.velocity.y = kolahtaa.velocity.y - 200;
				}
			}
		}
		
		private function wrap(obj:FlxObject):void
		{
			obj.x = (obj.x + obj.width / 2 + FlxG.width) % FlxG.width - obj.width / 2;
			obj.y = (obj.y + obj.height / 2) % FlxG.height - obj.height / 2;
		}
		
		private function vaihdaVuoroa():void
		{
			if(FlxG.keys.justPressed("ONE") && pelaajat.length >= 1)
			{
				vuorollinen = 0;
			}
			if(FlxG.keys.justPressed("TWO") && pelaajat.length >= 2)
			{
				vuorollinen = 1;
			}
			if(FlxG.keys.justPressed("THREE") && pelaajat.length >= 3)
			{
				vuorollinen = 2;
			}
			if(FlxG.keys.justPressed("FOUR") && pelaajat.length >= 4)
			{
				vuorollinen = 3;
			}
			if(FlxG.keys.justPressed("FIVE") && pelaajat.length >= 5)
			{
				vuorollinen = 4;
			}
		}
		
		private function luoKartta(kentta:int):void
		{
			if (kartta != null)
			{
				kartta.kill();
			}
			kartta = new FlxTilemap();
			
			pelaajat = [];
			
			tasolla = kentta;
			
			this.clear();
			
			if (kentta == 1) 
			{
				var taso1Image:Bitmap = new taso1Embed;
				pelitaso = taso1Image.bitmapData;
				var taso1:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(taso1, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				viesti = "Yöllä uneksin seikkailuista.";
				teksti = new FlxText(50,50,200,viesti,true);
				add(teksti);
				viesti = "Siitä kuinka elämä olisikin yllätyksiä täynnä.";
				teksti = new FlxText(100,100,300,viesti,true);
				add(teksti);
				viesti = "Huomasin oven, joka veti minua puoleensa.";
				teksti = new FlxText(100,130,300,viesti,true);
				add(teksti);
				viesti = "Mitä sieltä löytäisinkään?";
				teksti = new FlxText(150,150,200,viesti,true);
				add(teksti);
			}
			else if (kentta == 2) 
			{
				
				if (ekaKerta == false)
				{
					viesti = "Hui! Tuota en halua kokea uudestaan!";
					teksti = new FlxText(200,120,200,viesti,true);
					add(teksti);
				}
				
				var taso2Image:Bitmap = new taso2Embed;
				pelitaso = taso2Image.bitmapData;
				var taso2:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(taso2, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				viesti = "Innoissani huomasin seikkailun jatkuvan.";
				teksti = new FlxText(50,50,300,viesti,true);
				add(teksti);
				viesti = "Sen jännitys oli kutkuttavaa...";
				teksti = new FlxText(80,80,300,viesti,true);
				add(teksti);
				viesti = "Pelottavat kuilut aukenivat edessäni.";
				teksti = new FlxText(70,210,300,viesti,true);
				add(teksti);
				
			}
			else if (kentta == 3) 
			{
				FlxG.bgColor = 0xff6666ff;
				
				var taso3Image:Bitmap = new taso3Embed;
				pelitaso = taso3Image.bitmapData;
				var taso3:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(taso3, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				viesti = "Heräsin naama veikeässä hymyssä.";
				teksti = new FlxText(70,70,300,viesti,true);
				add(teksti);
				viesti = "Tajusin oikeankin elämän olevan seikkailua.";
				teksti = new FlxText(40,190,300,viesti,true);
				add(teksti);
				viesti = "Pitää vain elää positiivisesti!";
				teksti = new FlxText(220,240,300,viesti,true);
				add(teksti);
			}
			else if (kentta == 4) 
			{
				FlxG.bgColor = 0xff6666ff;
				
				var taso4Image:Bitmap = new taso4Embed;
				pelitaso = taso4Image.bitmapData;
				var taso4:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(taso4, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				if (ekaKerta == false)
				{
					viesti = "Ohhoh! Leuka pystyyn ja uutta yritystä.";
					teksti = new FlxText(20,90,300,viesti,true);
					add(teksti);
				}
				
				viesti = "Muuten...";
				teksti = new FlxText(240,30,300,viesti,true);
				add(teksti);
				viesti = "Minä olen Mika.";
				teksti = new FlxText(220,50,300,viesti,true);
				add(teksti);
				viesti = "Mukava saada elämässä apua.";
				teksti = new FlxText(40,170,300,viesti,true);
				add(teksti);
				viesti = "Kiitos Sinulle.";
				teksti = new FlxText(260,240,300,viesti,true);
				add(teksti);
			}
			else if (kentta == 5) 
			{
				FlxG.bgColor = 0xff6666ff;
				
				var taso5Image:Bitmap = new taso5Embed;
				pelitaso = taso5Image.bitmapData;
				var taso5:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(taso5, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				viesti = "Joitakin esteitä ei voi kohdata yksin.";
				teksti = new FlxText(30,20,300,viesti,true);
				add(teksti);
				viesti = "Tajusin, että voin saada apua.";
				teksti = new FlxText(90,40,300,viesti,true);
				add(teksti);
				viesti = "Minun täytyi vain painaa numeroa 2 tai 3.";
				teksti = new FlxText(70,70,300,viesti,true);
				add(teksti);
				viesti = "Voisimme kannatella toisemme esteen yli!";
				teksti = new FlxText(20,110,300,viesti,true);
				add(teksti);
				viesti = "Jännityksessä unohdin pystyväni liikkua painamalla numeroa 1.";
				teksti = new FlxText(50,150,400,viesti,true);
				add(teksti);
			}
			else if (kentta == 6) 
			{
				FlxG.bgColor = 0xff6666ff;
				
				var taso6Image:Bitmap = new taso6Embed;
				pelitaso = taso6Image.bitmapData;
				var taso6:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(taso6, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				viesti = "Mitä nyt? En yletä hyppäämään.";
				teksti = new FlxText(30,15,300,viesti,true);
				add(teksti);
				viesti = "Heittämällä pääsen kuitenkin korkealle.";
				teksti = new FlxText(180,50,300,viesti,true);
				add(teksti);
				viesti = "Alla olevan apurin täytyy vain 'hypätä'";
				teksti = new FlxText(100,170,300,viesti,true);
				add(teksti);
				viesti = "Yhteistyö on tärkeää!";
				teksti = new FlxText(270,220,300,viesti,true);
				add(teksti);
			}
			else if (kentta == 7) 
			{
				FlxG.bgColor = 0xff6666ff;
				
				var taso7Image:Bitmap = new taso7Embed;
				pelitaso = taso7Image.bitmapData;
				var taso7:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(taso7, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				if (ekaKerta == false)
				{
					viesti = "Aijai! Nyt tarvitaan rauhallisuutta.";
					teksti = new FlxText(30,180,300,viesti,true);
					add(teksti);
				}
				
				viesti = "Nyt alkaa näyttää pelottavalta.";
				teksti = new FlxText(100,30,300,viesti,true);
				add(teksti);
				viesti = "Emmeköhän me onnistu.";
				teksti = new FlxText(220,60,300,viesti,true);
				add(teksti);
				viesti = "Vai mitä?";
				teksti = new FlxText(200,160,300,viesti,true);
				add(teksti);
				viesti = "Voin muuten itsekin auttaa muita maaliin.";
				teksti = new FlxText(150,275,300,viesti,true);
				add(teksti);
			}
			else if (kentta == 8) 
			{
				FlxG.bgColor = 0xff6666ff;
				
				var taso8Image:Bitmap = new taso8Embed;
				pelitaso = taso8Image.bitmapData;
				var taso8:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(taso8, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				viesti = "Tässähän vaaditaan jo akrobatiaa!";
				teksti = new FlxText(50,20,300,viesti,true);
				add(teksti);
				viesti = "Kunnon venymiskykyä!";
				teksti = new FlxText(20,110,300,viesti,true);
				add(teksti);
				viesti = "Sitä löytyy STP:stä.";
				teksti = new FlxText(270,190,300,viesti,true);
				add(teksti);
				viesti = "Suomen Työväenpuolue";
				teksti = new FlxText(200,270,300,viesti,true);
				add(teksti);
			}
			else if (kentta == 9) 
			{
				FlxG.bgColor = 0xff6666ff;
				
				var taso9Image:Bitmap = new taso9Embed;
				pelitaso = taso9Image.bitmapData;
				var taso9:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(taso9, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				viesti = "Mika";
				teksti = new FlxText(50,110,300,viesti,true);
				add(teksti);
				viesti = "Salminen";
				teksti = new FlxText(120,80,300,viesti,true);
				add(teksti);
				viesti = "56";
				teksti = new FlxText(195,50,300,viesti,true);
				add(teksti);
				viesti = "Muista STP";
				teksti = new FlxText(270,200,300,viesti,true);
				add(teksti);
				viesti = "Todellinen työntekijän puolue";
				teksti = new FlxText(195,250,300,viesti,true);
				add(teksti);
			}
			else 
			{
				FlxG.bgColor = 0xff6666ff;
				
				var loppuImage:Bitmap = new loppuEmbed;
				pelitaso = loppuImage.bitmapData;
				var loppu:String = FlxTilemap.bitmapToCSV(pelitaso);
				kartta.loadMap(loppu, maa, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				asetaAlku();
				
				viesti = "Toivottavasti oli hauskaa.";
				teksti = new FlxText(50,20,300,viesti,true);
				add(teksti);
				viesti = "Minulla ainakin oli.";
				teksti = new FlxText(80,100,300,viesti,true);
				add(teksti);
				viesti = "Kiitos.";
				teksti = new FlxText(60,160,300,viesti,true);
				add(teksti);
				viesti = "Muistathan äänestää?";
				teksti = new FlxText(270,30,300,viesti,true);
				add(teksti);
				viesti = "56 Helsingissä";
				teksti = new FlxText(300,150,300,viesti,true);
				add(teksti);
			}
			add(kartta);

			vuorollinen = 0;
		}
			
		private function asetaAlku():void
		{
			var ukko:int = 0;
			for(var x:int = 0; x < pelitaso.width; x++)
			{
				for (var y:int = 0; y < pelitaso.height; y++)
				{
					if (pelitaso.getPixel(x,y) == 0xff0000)
					{
						luoPelaaja(ukko,x*16,y*16);
						ukko++;
					}
					if (pelitaso.getPixel(x,y) == 0xffff00)
					{
						maali = new FlxSprite(x*16,y*16);
						maali.loadGraphic(ovi);
						add(maali);
					}
				}
			}
			
			
			
		}
		
		private function restart():void
		{
			ekaKerta = false;
			luoKartta(tasolla);
		}
		
		private function paastyMaaliin(sankari:FlxObject, loppu:FlxObject):void
		{
			ekaKerta = true;
			luoKartta(tasolla + 1);;
		}
	}
}