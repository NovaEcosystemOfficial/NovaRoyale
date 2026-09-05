/** Known Clash Royale API endpoint paths (relative to /v1). */
export const CR_ENDPOINTS = {
  player: (encodedTag: string) => `/players/${encodedTag}`,
  playerBattleLog: (encodedTag: string) => `/players/${encodedTag}/battlelog`,
  playerUpcomingChests: (encodedTag: string) =>
    `/players/${encodedTag}/upcomingchests`,
  clan: (encodedTag: string) => `/clans/${encodedTag}`,
  clanMembers: (encodedTag: string) => `/clans/${encodedTag}/members`,
  cards: () => "/cards",
  locations: () => "/locations",
} as const;

export type CrEndpointKey = keyof typeof CR_ENDPOINTS;
