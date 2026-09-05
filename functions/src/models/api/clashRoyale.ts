/** Shapes returned by the official Clash Royale API. */

export interface CrApiPlayer {
  tag: string;
  name: string;
  expLevel: number;
  trophies: number;
  bestTrophies: number;
  wins: number;
  losses: number;
  battleCount: number;
  threeCrownWins: number;
  challengeCardsWon: number;
  challengeMaxWins: number;
  tournamentCardsWon: number;
  tournamentBattleCount: number;
  role?: string;
  donations: number;
  donationsReceived: number;
  totalDonations: number;
  warDayWins: number;
  clanCardsCollected: number;
  clan?: CrApiPlayerClan;
  arena?: CrApiArena;
  leagueStatistics?: CrApiLeagueStatistics;
  badges?: CrApiBadge[];
  achievements?: CrApiAchievement[];
  cards?: CrApiPlayerCard[];
  currentDeck?: CrApiPlayerCard[];
  currentFavouriteCard?: CrApiPlayerCard;
  starPoints?: number;
  expPoints?: number;
}

export interface CrApiPlayerClan {
  tag: string;
  name: string;
  badgeId: number;
}

export interface CrApiArena {
  id: number;
  name: string;
}

export interface CrApiLeagueStatistics {
  currentSeason?: {id: number; trophies: number; bestTrophies: number};
  previousSeason?: {id: number; trophies: number; bestTrophies: number};
  bestSeason?: {id: number; trophies: number};
}

export interface CrApiBadge {
  name: string;
  level?: number;
  maxLevel?: number;
  progress?: number;
  target?: number;
  /** CR API may include an empty-string key; strip before Firestore writes. */
  iconUrls?: Record<string, string>;
}

export interface CrApiAchievement {
  name: string;
  stars: number;
  value: number;
  target: number;
  info: string;
  completionInfo?: string;
}

export interface CrApiPlayerCard {
  name: string;
  id: number;
  level: number;
  maxLevel: number;
  rarity: string;
  count: number;
  elixirCost?: number;
  iconUrls?: {medium: string};
}

export interface CrApiBattle {
  type: string;
  battleTime: string;
  isLadderTournament?: boolean;
  arena?: CrApiArena;
  gameMode?: {id: number; name: string};
  deckSelection?: string;
  team: CrApiBattleSide[];
  opponent: CrApiBattleSide[];
}

export interface CrApiBattleSide {
  tag: string;
  name: string;
  startingTrophies?: number;
  trophyChange?: number;
  crowns: number;
  kingTowerHitPoints?: number;
  princessTowersHitPoints?: number[];
  clan?: CrApiPlayerClan;
  cards?: CrApiPlayerCard[];
  supportCards?: CrApiPlayerCard[];
  globalRank?: number;
  elixirLeaked?: number;
}

export interface CrApiUpcomingChests {
  items: CrApiChestItem[];
}

export interface CrApiChestItem {
  index: number;
  name: string;
}

export interface CrApiClan {
  tag: string;
  name: string;
  type: string;
  description: string;
  badgeId: number;
  clanScore: number;
  clanWarTrophies: number;
  location?: {id: number; name: string; isCountry: boolean; countryCode?: string};
  requiredTrophies: number;
  donationsPerWeek: number;
  clanChestStatus?: string;
  clanChestLevel?: number;
  clanChestMaxLevel?: number;
  members: number;
}

export interface CrApiClanMember {
  tag: string;
  name: string;
  role: string;
  expLevel: number;
  trophies: number;
  arena?: CrApiArena;
  clanRank: number;
  previousClanRank: number;
  donations: number;
  donationsReceived: number;
}

export interface CrApiCard {
  name: string;
  id: number;
  maxLevel: number;
  iconUrls: {medium: string};
  rarity: string;
  elixirCost?: number;
}

export interface CrApiCardsResponse {
  items: CrApiCard[];
  supportItems?: CrApiCard[];
}
