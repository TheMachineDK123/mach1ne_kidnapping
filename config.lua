Config = {}

Config.Debug = false

Config.Cooldown = 0

Config.Boss = {
    model = 'a_m_m_soucent_02',
    pos = vector3(-1383.1, -640.04, 28.6733),
    heading = 211.53,
}

Config.VictimSpawns = {
    { pos = vector3(-833.02, -350.74, 38.6802), heading = 243.42 },
    { pos = vector3(-197.90, -864.60, 29.3243), heading = 246.03 },
    { pos = vector3(-20.242, -1721.1, 29.2882), heading = 22.81 },
}

Config.QueryRoom = {
    scenePos = vector3(568.450, -3123.8, 18.7686),
    sceneRot = vector3(0.0, 0.0, -90.0),
    laptopScenePos = vector3(565.9, -3123.0, 18.7686),
    laptopSceneRot = vector3(0.0, 0.0, 0.0),
    tripodPos = vector3(570.572, -3123.8, 17.7086),
    cameraPos = vector3(570.572, -3123.755, 19.2986),
    cameraHeading = -90.0,
    blip = { sprite = 364, color = 0, label = 'Forhørslokale' },
}

Config.VictimModel = 'a_m_m_prolhost_01'

Config.VideoItem = 'videorecord'

Config.RewardCashMin = 25000
Config.RewardCashMax = 50000

Config.RandomRewardItems = {
    'bread',
    'water',
}

Config.PoliceJobs = { 'police', 'sheriff', 'fib' }

Config.InteractDist = 2.5
Config.DisplayDist = 4.0

Config.Objects_1 = { 'prop_cs_wrench' }
Config.Anims_1 = {
    {'wrench_idle_player', 'wrench_idle_victim', 'wrench_idle_chair', 'wrench_idle_wrench'},
    {'wrench_attack_left_player', 'wrench_attack_left_victim', 'wrench_attack_left_chair', 'wrench_attack_left_wrench'},
    {'wrench_attack_mid_player', 'wrench_attack_mid_victim', 'wrench_attack_mid_chair', 'wrench_attack_mid_wrench'},
    {'wrench_attack_right_player', 'wrench_attack_right_victim', 'wrench_attack_right_chair', 'wrench_attack_right_wrench'},
}

Config.Objects_2 = { 'w_am_jerrycan', 'p_loose_rag_01_s' }
Config.Anims_2 = {
    {'waterboard_idle_player', 'waterboard_idle_victim', 'waterboard_idle_chair', 'waterboard_idle_jerrycan', 'waterboard_idle_rag'},
    {'waterboard_kick_player', 'waterboard_kick_victim', 'waterboard_kick_chair', 'waterboard_kick_jerrycan', 'waterboard_kick_rag'},
    {'waterboard_loop_player', 'waterboard_loop_victim', 'waterboard_loop_chair', 'waterboard_loop_jerrycan', 'waterboard_loop_rag'},
    {'waterboard_outro_player', 'waterboard_outro_victim', 'waterboard_outro_chair', 'waterboard_outro_jerrycan', 'waterboard_outro_rag'},
}

Config.Objects_3 = { 'prop_pliers_01' }
Config.Anims_3 = {
    {'pull_tooth_intro_player', 'pull_tooth_intro_victim', 'pull_tooth_intro_pliers'},
    {'pull_tooth_idle_player', 'pull_tooth_idle_victim', 'pull_tooth_idle_pliers'},
    {'pull_tooth_loop_player', 'pull_tooth_loop_victim', 'pull_tooth_loop_pliers'},
    {'pull_tooth_outro_b_player', 'pull_tooth_outro_b_victim', 'pull_tooth_outro_b_pliers'},
}

Strings = {
    ['attack_left']      = 'Slå til venstre',
    ['attack_mid']       = 'Slå midt',
    ['attack_right']     = 'Slå til højre',
    ['switch_jerrycan']  = 'Skift jerrycan',
    ['switch_pliers']    = 'Skift tænger',
    ['tooth_pull']       = 'Træk tand',
    ['tooth_rip']        = 'Ryk tand ud',
    ['blindfold']        = 'Læg hætte på offer',
    ['cant_blindfold']   = 'Du er for langt væk',
    ['drop_chair']       = 'Læg stolen ned',
    ['pour_gasoline']    = 'Hæld benzin',
    ['up_chair']         = 'Rejs stolen op',
    ['leave_vehicle']    = 'Bed offer om at stige ud',
    ['start_query']      = 'Start forhør',

    ['get_job']          = 'Tag imod missionen',
    ['finish_job']       = 'Aflevere videooptagelse',
    ['get_videorecord']  = 'Hent videooptagelse',
    ['check_videorecord']= 'Tjek videooptagelse',
    ['go_laptop']        = 'Gå til laptop for at tjekke videooptagelsen.',
    ['go_query']         = 'Kør til forhørslokalet.',

    ['police_alert']     = 'Kidnapping alarm! Tjek din GPS.',
    ['query_room_busy']  = 'Forhørslokalet er optaget, vent lidt.',
    ['wait_nextnapping'] = 'Du skal vente så længe før du kan kidnappe igen:',
    ['minute']           = 'minut(ter).',
    ['mission_failed']   = 'Missionen fejlede. Offeret er død.',
    ['mission_failed2']  = 'Missionen fejlede. Du kom for langt væk fra offeret.',

    ['kidnap_blip']      = 'Person der skal kidnappes',
    ['boss_blip']        = 'Sælg videooptagelse',
    ['query_blip']       = 'Forhørslokale',

    ['info_1']           = 'Jeg vil have dig til at finde en person. Tjek din GPS. Der er et par ting du skal spørge ham om.',
    ['info_2']           = 'Du kan løslade ham efter du har fået svar. Du SKAL have svarerne.',
    ['info_3']           = 'Glem ikke at optage videoen!',

    ['reward_cash']      = 'Du fik %d kr. for videooptagelsen',
    ['reward_item']      = 'Du fik også: %s',
}
