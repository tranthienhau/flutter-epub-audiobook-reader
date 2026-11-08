"""Builds the demo content the app ships with.

- assets/books/*.epub   real EPUB 3 packages (container.xml, OPF, nav, XHTML chapters)
- assets/audio/*.m4a    narration rendered with the macOS `say` voice "Karen" (en_AU)

Run from the repo root: python3 tool/build_content.py
"""
import os
import subprocess
import zipfile
from html import escape

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BOOKS = os.path.join(ROOT, "assets", "books")
AUDIO = os.path.join(ROOT, "assets", "audio")

SALT_ROAD = [
    ("Port Fairy", [
        "The tide had pulled away from the stone jetty, leaving kelp and salt crust in the crevices. Meg Calloway stood at the end of it with her boots soaked through and watched the whaleboats drag their shadows across the bay.",
        "Her father had promised the drove would leave on the first dry morning. There had been no dry mornings in a fortnight. The wind came off the Southern Ocean with nothing to stop it until it reached the cottages, and then it found every gap in the timber.",
        "She was seventeen, and she had never been further east than the Moyne River bridge. By the end of winter she would know the whole length of the coast road, every creek crossing and every publican who watered his rum.",
    ]),
    ("The Drover's Daughter", [
        "Six hundred head of Hereford cross, two dogs, one cook and a boy from Koroit who could not keep his hat on his head. That was the drove.",
        "Her father rode at the front with the ledger buttoned inside his coat. Meg rode the wing, where the dust was thinnest and the work was hardest, because a drover's daughter who rode drag would never be asked to ride anything else.",
        "On the third night they camped beside a dam the colour of strong tea. The cook burnt the damper. The boy from Koroit lost his hat to the dam. Nobody spoke of the bank in Warrnambool, though everybody was thinking of it.",
    ]),
    ("The Coach Road", [
        "The team rattled past the ghost gums at midday, dust rising in amber plumes behind the wheels. The Cobb and Co coach did not slow for cattle, and cattle did not slow for anyone.",
        "Meg kept the mob to the left of the road and raised her hand to the driver. He raised his whip in reply. A woman in a blue bonnet watched her from the window as if she were a bushranger or a circus act.",
        "That night her father told her the price of beef had fallen again. He said it the way other men said a prayer, quietly and to nobody in particular.",
    ]),
    ("Warrnambool Fair", [
        "The fair smelled of toffee, wet wool and horse. Meg sold two of her own heifers to a Scotsman with a beard like a hedge and tucked the coins into her boot.",
        "She found her father outside the bank with his hat in his hands. He did not go in. He looked at the door for a long time and then he walked back to the camp, and she understood that the drove was no longer a choice.",
    ]),
    ("Salt and Iron", [
        "She paused by the iron gate, where rusted wire caught the morning mist like beaten copper. Beyond it the land fell away toward the sea in long pale folds.",
        "The gate belonged to a selector named Hannigan, who wanted a shilling a head to cross his paddock. Her father offered sixpence. Hannigan offered his shotgun. In the end Meg offered the Scotsman's coins, and the mob went through like water.",
        "Her father said nothing for eleven miles. Then he said, You did right, and nothing else for the rest of the day.",
    ]),
    ("The Bitter Tide", [
        "Rain came in sideways across the flats and the creeks rose overnight. The boy from Koroit was the first to see that the ford was gone.",
        "They swam the cattle across at dawn, two hundred at a time, with the dogs barking themselves hoarse on the far bank. Meg lost a stirrup in the current and found it again a mile downstream, wrapped around the root of a red gum like a promise.",
    ]),
    ("The Long Paddock", [
        "The frost had settled early across the southern paddocks, turning the dry spear-grass into a brittle, shimmering crust beneath the mare's hooves. Meg rode with the reins slack between two gloved fingers, listening to the wire fence hum in the salt wind that swept up off the bight.",
        "In this light, between the setting of the winter moon and the first pale blush above the ridge, the boundary fence seemed less like a fence and more like a spine holding the timber country to the sea.",
        "She knew every post by heart, the split red gum, the ironbark weathered to silver, the notch her father had cut the summer the drought finally broke.",
        "The paddock ran silver under the moon and the fence wire sang with the first cold gust off the bight. Somewhere behind her the mob shifted and settled, six hundred breaths turning to fog.",
        "Far out on the darkening water, a single coastal steamer pressed eastward toward Melbourne, its masthead lantern blinking once, twice, before the sea mist swallowed it whole.",
        "She thought of the bank, and the ledger inside her father's coat, and the Scotsman's coins that were no longer in her boot. She thought of how little of it mattered out here, where the only debt was to the grass and the only interest was the weather.",
        "At the bend in the track the old drover's hut came into view, its chimney crooked, its door hanging from one hinge. Her father had slept there as a boy. He had told her so a hundred times, and she had never once believed him.",
        "Now, with the frost on the roof and a thin curl of smoke rising from the chimney, she believed him completely. Someone had lit a fire. Someone was waiting.",
        "Meg touched her heels to the mare and rode toward the light.",
    ]),
    ("Home Paddock", [
        "It was her mother in the hut, of course. She had come down from Ballarat on the mail coach with a letter from the bank and a pot of mutton stew, and she had been waiting three days.",
        "The letter said the loan would hold until spring. The stew said everything else.",
    ]),
]

SHORT_BOOKS = {
    "red-dirt-country": ("Red Dirt Country", "Sam Okafor", [
        ("The Station", ["The road to Kalkarindji was four hundred kilometres of corrugations and kites circling over road kill. Ade drove it with the windows down because the air conditioning had died at Katherine.", "The station manager met him at the gate with a dog that looked like a fox and a handshake like a vice."]),
        ("Wet Season", ["When the rain came it came all at once, turning the red dirt to a river of rust. Ade sat on the verandah and watched the creek take the fence, the track and finally the ute."]),
    ]),
    "notes-from-hobart": ("Notes from Hobart", "Ruth Lim", [
        ("Salamanca", ["Saturday mornings smell of wood smoke and apples. The market stalls open before the light does, and the mountain wears its cloud like a borrowed coat."]),
        ("The Ferry", ["The ferry to Bellerive crosses the Derwent in twelve minutes. In winter I take it twice, there and back, just to sit in the warm cabin and watch the water."]),
    ]),
    "quiet-coast": ("The Quiet Coast", "Ava Bennett", [
        ("Low Water", ["Nobody went to Mallacoota in July except the people who never left. Iris arrived on a Tuesday with one suitcase and a key to a house she had never seen."]),
    ]),
    "year-of-small-things": ("A Year of Small Things", "Lily Tran", [
        ("January", ["Buy flowers for no reason. Put them in the jug that was your grandmother's. Notice that the kitchen feels different, and let it."]),
        ("February", ["Walk to the end of the street and back without your phone. Count the letterboxes. There are more than you think."]),
    ]),
    "paper-trails": ("Paper Trails", "Clare Whitfield", [
        ("The Bundle", ["The letters were tied with garden twine and tucked behind the hot water service. Sixty-one of them, all addressed to a woman who had never lived in the house."]),
    ]),
}

HARBOUR_LIGHTS_CH12 = (
    "Chapter twelve. Low Tide. "
    "The ferry left Circular Quay at ten past eleven, the last run of the night, and Nell was the only passenger on the upper deck. "
    "Below her the harbour was black and slick as oil, broken only by the long gold ribbons of the city lights. "
    "She had not meant to stay out so late. She had meant to say what she came to say, and then go home. "
    "But Daniel had ordered another bottle, and the wind had dropped, and for a little while it had felt like the old days, before the shop, before the loan, before her mother's letters started arriving every Monday like a tide that would not turn. "
    "Now the bridge slid overhead, all rivets and shadow, and she pulled her coat tighter. "
    "At Neutral Bay a deckhand in a yellow jacket threw the rope and missed. He laughed, and tried again, and the second time it caught. "
    "Nell watched the rope pull taut and thought, that is all anyone really wants. A second chance at the throw."
)

DAILY_ESSAY = (
    "Why we still write letters. By Clare Whitfield. "
    "In the morning light of the Blackheath post office, Mrs Higgins still weighs parcels on brass scales that have outlived three postal ministers. "
    "There is something quietly stubborn about dropping an envelope into the red pillar box on the corner, the hollow thud as it falls into darkness, beginning its slow journey across blue gum valleys and sun-baked roads. "
    "We send messages across satellites in milliseconds now, yet none of them smell of cedar drawers or carry the hesitation of an inked cross-out. "
    "A handwritten note asks you to sit still with one person in your mind. A letter is a small promise that someone will still be there when it arrives."
)


def slug(s):
    return "".join(c if c.isalnum() else "-" for c in s.lower()).strip("-")


def write_epub(path, book_id, title, author, chapters):
    with zipfile.ZipFile(path, "w") as z:
        z.writestr("mimetype", "application/epub+zip", compress_type=zipfile.ZIP_STORED)
        z.writestr(
            "META-INF/container.xml",
            '<?xml version="1.0"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
            '<rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>',
        )
        manifest, spine, nav = [], [], []
        for i, (ctitle, paras) in enumerate(chapters, 1):
            fid = f"ch{i:02d}"
            body = "".join(f"<p>{escape(p)}</p>" for p in paras)
            z.writestr(
                f"OEBPS/{fid}.xhtml",
                '<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml">'
                f"<head><title>{escape(ctitle)}</title></head><body><h1>{escape(ctitle)}</h1>{body}</body></html>",
            )
            manifest.append(f'<item id="{fid}" href="{fid}.xhtml" media-type="application/xhtml+xml"/>')
            spine.append(f'<itemref idref="{fid}"/>')
            nav.append(f'<li><a href="{fid}.xhtml">{escape(ctitle)}</a></li>')
        z.writestr(
            "OEBPS/nav.xhtml",
            '<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">'
            f'<head><title>Contents</title></head><body><nav epub:type="toc"><ol>{"".join(nav)}</ol></nav></body></html>',
        )
        z.writestr(
            "OEBPS/content.opf",
            '<?xml version="1.0" encoding="utf-8"?><package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="bid">'
            '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'
            f'<dc:identifier id="bid">urn:inkwell:{book_id}</dc:identifier><dc:title>{escape(title)}</dc:title>'
            f"<dc:creator>{escape(author)}</dc:creator><dc:language>en-AU</dc:language></metadata>"
            f'<manifest><item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>{"".join(manifest)}</manifest>'
            f'<spine>{"".join(spine)}</spine></package>',
        )


def narrate(text, name):
    aiff = os.path.join(AUDIO, name + ".aiff")
    m4a = os.path.join(AUDIO, name + ".m4a")
    subprocess.run(["say", "-v", "Karen", "-r", "165", "-o", aiff, text], check=True)
    subprocess.run(["afconvert", "-f", "m4af", "-d", "aac", "-b", "64000", aiff, m4a], check=True)
    os.remove(aiff)


if __name__ == "__main__":
    os.makedirs(BOOKS, exist_ok=True)
    os.makedirs(AUDIO, exist_ok=True)
    write_epub(os.path.join(BOOKS, "salt-road.epub"), "salt-road", "The Salt Road", "Eleanor Marsh", SALT_ROAD)
    for bid, (t, a, ch) in SHORT_BOOKS.items():
        write_epub(os.path.join(BOOKS, f"{bid}.epub"), bid, t, a, ch)
    narrate(HARBOUR_LIGHTS_CH12, "harbour-lights-ch12")
    title, paras = SALT_ROAD[6]
    narrate(f"Chapter seven. {title}. " + " ".join(paras), "salt-road-ch07")
    narrate(DAILY_ESSAY, "daily-letters")
    print("ok")
