# Inkwell - Design System

Bright, warm, modern mobile reading + listening app for an Australian publisher. Light theme only.

## Color (use ONLY these colors; no default violet/indigo, no flat neutral grey)
- Background (page): #FCF4F6 (warm blush near-white)
- Surface (cards, sheets, tab bar): #FFFFFF
- Surface alt (grouped rows): #F8EDF0
- Reader paper (EPUB page background): #FBF6EE
- Accent (large fills, icons, active states, big numerals): #FB7299 sakura pink
- Accent fill (buttons/chips carrying WHITE labels, links): #AB4766
- Accent pressed: #A14862
- Accent tint (selected fills, badges): #FEE6ED
- Support (secondary data, highlights, premium badge fill): #B6E36A lime
- Support strong (progress lines, chart series): #72A21F
- Text primary #1F0C11, secondary #5C454C, tertiary #806A70
- Border hairline #EFDDE2, input/control border #B7898E
- Status text on tint: success #0E7C3A on #E3F4E9, warning #A75906 on #FAEFE1, danger #CE2020 on #FBE5E5
- Hero gradient behind white text: #AB4766 -> #A14862 (nothing lighter). A soft #FB7299 -> #B6E36A blend is decoration only, never behind text.

## Typography
- UI + body: M PLUS Rounded 1c. Display / hero titles: Baloo 2.
- Display 32/700 (-0.02em), Title 20/700, Body 16/400 (reader body 18/1.6), Label 14/600, Caption 13/500.
- Use only these 5 sizes (plus reader body). Minimum text 12px; chips and tags 13px; legal text 14px.

## Frame + safe areas
- 393x852 (iPhone 16/17). Keep top ~59px and bottom ~34px clear of tappable content.

## Shape, spacing, elevation, icons
- Radius: card 20, control 14, input 12, pill 999. Book covers 10px radius with soft shadow.
- 8pt spacing (4, 8, 12, 16, 24, 32), edge padding 20px.
- Elevation: soft only, card = 0 1px 2px rgba(31,12,17,.04) + 0 8px 24px rgba(31,12,17,.06).
- Icons: one set, rounded outline (Lucide style), 24px, 1.75 stroke. Never mix filled + outline (filled heart/bookmark allowed only for the active state).

## Controls (one spec, reused everywhere)
- Primary button: pill, #AB4766 fill, white 16/600 label; pressed #A14862; disabled 40% opacity.
- Secondary button: pill, white, 1.5px #B7898E outline, #1F0C11 label.
- Input: 12px radius, white, #B7898E border; focus 2px #FB7299 ring; error #CE2020 border + caption.
- Card: 20px radius, white, soft shadow.
- Chip: pill 13/600, #FEE6ED fill with #AB4766 text; selected #AB4766 fill with white text. On a gradient, chips use a dark translucent fill.
- Premium badge: small pill, #B6E36A fill, #1F0C11 text, crown icon.
- Progress bar: 4px, track #F8EDF0, fill #FB7299.

## Shared components
- Bottom tab bar (flat white, hairline top border), exactly 4 tabs in this order: Today (sun icon), Library (book-open icon), Search (search icon), Profile (user icon). Active tab: icon + label in #AB4766 with small #FEE6ED pill behind the icon. Inactive: #806A70. Never rename, reorder, add or remove tabs.
- Mini player (on Today, Library, Search when audio is loaded): white card directly above the tab bar, 48px cover thumb, title + author, play/pause in #AB4766 circle, thin #FB7299 progress line on top edge.
- Status bar: iOS standard.

## Imagery
- Real photography only: people reading, landscapes, real book covers (photographic or typographic cover art). Empty states and onboarding also use real photos or flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects.

## Focal rule
- One bold focal element per screen (hero card, big cover, big play button). Everything else quiet.

## Color meaning
- Red only for errors and destructive actions. Non-urgent notices use the warning color with an icon.

## Copy scope
- Do not mention: AI narrator, Kindle, Audible, NFT, Crypto, Podcast ads. No invented integrations. Prices in AUD (A$). Australian spelling (favourites, colour).
