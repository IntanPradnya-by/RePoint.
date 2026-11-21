import { computed, ref } from 'vue'
import { categories, items } from '../data/items'

export function useItemFilter() {
  const searchQuery = ref('')
  const activeCategory = ref('semua')

  const filteredItems = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()

    return items.filter((item) => {
      const matchesCategory = activeCategory.value === 'semua' || item.category === activeCategory.value
      const matchesQuery =
        !query ||
        item.title.toLowerCase().includes(query) ||
        item.summary.toLowerCase().includes(query) ||
        item.description.toLowerCase().includes(query)

      return matchesCategory && matchesQuery
    })
  })

  function resetFilters() {
    searchQuery.value = ''
    activeCategory.value = 'semua'
  }

  return {
    categories,
    searchQuery,
    activeCategory,
    filteredItems,
    resetFilters
  }
}
