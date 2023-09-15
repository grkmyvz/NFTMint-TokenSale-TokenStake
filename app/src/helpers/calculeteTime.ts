export function formatTimeDiff(timestamp: number) {
  const now = Math.floor(Date.now() / 1000);
  const diff = timestamp - now;

  const days = Math.floor(diff / 86400);
  const hours = Math.floor((diff % 86400) / 3600);
  const minutes = Math.floor((diff % 3600) / 60);

  if (minutes < 0) {
    return "Complated";
  } else {
    return `${days} d ${hours} h ${minutes} m`;
  }
}
