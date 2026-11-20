/* See LICENSE file for copyright and license details. */
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0;    /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static const unsigned int gappih    = 20;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 30;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "JetBrainsMono Nerd Font:size=10", "monospace:size=10" };
static const char dmenufont[]       = "JetBrainsMono Nerd Font:size=10";
/* Tokyo-Night-artiges Farbschema */
static const char col_gray1[]       = "#1a1b26"; /* bar background      */
static const char col_gray2[]       = "#2f3549"; /* inactive border     */
static const char col_gray3[]       = "#a9b1d6"; /* normal text         */
static const char col_gray4[]       = "#1a1b26"; /* text on selection   */
static const char col_cyan[]        = "#7aa2f7"; /* selection / accent  */
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging */
/* 1 term, 2 web, 3 code, 4 files, 5 chat, 6 music, 7 docs, 8 media, 9 misc */
static const char *tags[] = { "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  " };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 * isterminal: windows started from it get swallowed (swallow patch)
	 * noswallow:  never swallow this window
	 * scratchkey: marks the window as the scratchpad with that key
	 */
	/* class                  instance        title           tags mask  float  term  noswal  mon  scratch */
	{ "Gimp",                 NULL,           NULL,           0,         1,     0,    0,      -1,  0 },
	{ "firefox",              NULL,           NULL,           1 << 1,    0,     0,    1,      -1,  0 }, /* tag 2: web */
	{ "st-256color",          NULL,           NULL,           0,         0,     1,    0,      -1,  0 }, /* st: swallows GUI apps it starts */
	{ "Pavucontrol",          NULL,           NULL,           0,         1,     0,    0,      -1,  0 },
	{ "pavucontrol",          NULL,           NULL,           0,         1,     0,    0,      -1,  0 },
	{ "Nm-connection-editor", NULL,           NULL,           0,         1,     0,    0,      -1,  0 },
	{ "Arandr",               NULL,           NULL,           0,         1,     0,    0,      -1,  0 },
	{ "flameshot",            NULL,           NULL,           0,         1,     0,    0,      -1,  0 },
	{ "obsidian",             NULL,           NULL,           1 << 6,    0,     0,    1,      -1,  0 }, /* tag 7: docs */
	{ "burp",                 NULL,           NULL,           1 << 8,    0,     0,    1,      -1,  0 }, /* tag 9: Burp Suite, not swallowed by st */
	{ "KeePassXC",            NULL,           NULL,           0,         1,     0,    0,      -1,  0 },
	{ "Proton Pass",          NULL,           NULL,           0,         1,     0,    0,      -1,  0 },
	{ NULL,                   "statuspopup",  NULL,           0,         1,     0,    0,      -1,  0 }, /* bar popups */
	{ NULL,                   NULL,           "Event Tester", 0,         0,     0,    1,      -1,  0 }, /* xev */
	{ NULL,                   "spterm",       NULL,           0,         1,     1,    0,      -1,  's' },
	{ NULL,                   "spcalc",       NULL,           0,         1,     1,    0,      -1,  'c' },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int refreshrate = 120;  /* refresh rate (per second) for client move/resize */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "[M]",      monocle },
	{ "[@]",      spiral },
	{ "[\\]",     dwindle },
	{ "H[]",      deck },
	{ "TTT",      bstack },
	{ "===",      bstackhoriz },
	{ "HHH",      grid },
	{ "###",      nrowgrid },
	{ "---",      horizgrid },
	{ ":::",      gaplessgrid },
	{ "|M|",      centeredmaster },
	{ ">M>",      centeredfloatingmaster },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ NULL,       NULL },
};

/* key definitions */
#define MODKEY Mod4Mask  /* Super; gap keys below use Super+Alt */
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char *termcmd[]  = { "st", NULL };
static const char *volupcmd[]   = { "wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", "5%+", NULL };
static const char *voldowncmd[] = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-", NULL };
static const char *volmutecmd[] = { "wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle", NULL };
static const char *micmutecmd[] = { "wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle", NULL };
static const char *shotcmd[]    = { "flameshot", "gui", NULL };
static const char *lockcmd[]    = { "lock", NULL };
static const char *powercmd[]   = { "dmenu-power", NULL };
static const char *clipcmd[]    = { "clipmenu", "-i", "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char *brupcmd[]    = { "brightnessctl", "-q", "set", "5%+", NULL };
static const char *brdowncmd[]  = { "brightnessctl", "-q", "--min-value=1%", "set", "5%-", NULL };
static const char *playcmd[]    = { "playerctl", "play-pause", NULL };
static const char *nextcmd[]    = { "playerctl", "next", NULL };
static const char *prevcmd[]    = { "playerctl", "previous", NULL };
static const char *stopcmd[]    = { "playerctl", "stop", NULL };
/* scratchpads: first element is the scratchkey from the rules above */
static const char *spterm[] = { "s", "st", "-n", "spterm", "-g", "120x34", NULL };
static const char *spcalc[] = { "c", "st", "-n", "spcalc", "-g", "70x20", "-e", "python3", "-q", NULL };
/* clickable status: runs `statuscmd <block> <button>` (blocks are marked
 * with \x01, \x02, ... in slstatus/config.h, see dwm-statusclick) */
static const char *statuscmd   = "dwm-statusclick";

static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_grave,  togglescratch,  {.v = spterm } },
	{ MODKEY,                       XK_apostrophe, togglescratch, {.v = spcalc } },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_j,      movestack,      {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_k,      movestack,      {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_h,      setcfact,       {.f = +0.25} },
	{ MODKEY|ShiftMask,             XK_l,      setcfact,       {.f = -0.25} },
	{ MODKEY|ShiftMask,             XK_o,      setcfact,       {.f =  0.00} },
	{ MODKEY,                       XK_Return, zoom,           {0} },
	{ MODKEY|Mod1Mask,              XK_u,      incrgaps,       {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_u,      incrgaps,       {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_i,      incrigaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_i,      incrigaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_o,      incrogaps,      {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_o,      incrogaps,      {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_6,      incrihgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_6,      incrihgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_7,      incrivgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_7,      incrivgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_8,      incrohgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_8,      incrohgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_9,      incrovgaps,     {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_9,      incrovgaps,     {.i = -1 } },
	{ MODKEY|Mod1Mask,              XK_0,      togglegaps,     {0} },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_0,      defaultgaps,    {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_o,      setlayout,      {.v = &layouts[13]} }, /* floating layout ><> */
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ControlMask,           XK_comma,  cyclelayout,    {.i = -1 } },
	{ MODKEY|ControlMask,           XK_period, cyclelayout,    {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_f,      togglefullscr,  {0} },
	{ MODKEY,                       XK_v,      spawn,          {.v = clipcmd } },
	{ MODKEY|ShiftMask,             XK_e,      spawn,          {.v = powercmd } },
	{ 0,                            XF86XK_MonBrightnessUp,   spawn, {.v = brupcmd } },
	{ 0,                            XF86XK_MonBrightnessDown, spawn, {.v = brdowncmd } },
	{ 0,                            XF86XK_AudioPlay,         spawn, {.v = playcmd } },
	{ 0,                            XF86XK_AudioPause,        spawn, {.v = playcmd } },
	{ 0,                            XF86XK_AudioNext,         spawn, {.v = nextcmd } },
	{ 0,                            XF86XK_AudioPrev,         spawn, {.v = prevcmd } },
	{ 0,                            XF86XK_AudioStop,         spawn, {.v = stopcmd } },
	{ 0,                            XF86XK_AudioRaiseVolume, spawn, {.v = volupcmd } },
	{ 0,                            XF86XK_AudioLowerVolume, spawn, {.v = voldowncmd } },
	{ 0,                            XF86XK_AudioMute,        spawn, {.v = volmutecmd } },
	{ 0,                            XF86XK_AudioMicMute,     spawn, {.v = micmutecmd } },
	{ 0,                            XK_Print,  spawn,          {.v = shotcmd } },
	{ MODKEY|ShiftMask,             XK_x,      spawn,          {.v = lockcmd } },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
	{ MODKEY|ShiftMask,             XK_r,      quit,           {1} }, /* restart in place */
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button1,        statusclick,    {0} },
	{ ClkStatusText,        0,              Button2,        statusclick,    {0} },
	{ ClkStatusText,        0,              Button3,        statusclick,    {0} },
	{ ClkStatusText,        0,              Button4,        statusclick,    {0} },
	{ ClkStatusText,        0,              Button5,        statusclick,    {0} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

