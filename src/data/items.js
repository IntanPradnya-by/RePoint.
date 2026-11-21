export const categories = [
  {
    id: 'cat-001',
    slug: 'plastik',
    title: 'Plastik',
    description: 'Botol, gelas, dan kemasan plastik yang bersih dan kering.'
  },
  {
    id: 'cat-002',
    slug: 'kertas',
    title: 'Kertas',
    description: 'Kertas bekas seperti koran, majalah, dan buku tulis yang tidak basah.'
  },
  {
    id: 'cat-003',
    slug: 'kardus',
    title: 'Kardus',
    description: 'Kardus bekas kemasan yang sudah dilipat dan tidak berminyak.'
  },
  {
    id: 'cat-004',
    slug: 'logam',
    title: 'Logam',
    description: 'Kaleng minuman dan logam bekas yang sudah dibersihkan.'
  },
  {
    id: 'cat-005',
    slug: 'kaca',
    title: 'Kaca',
    description: 'Botol dan wadah kaca bekas yang utuh dan tidak pecah.'
  },
  {
    id: 'cat-006',
    slug: 'organik',
    title: 'Organik',
    description: 'Sisa makanan dan dedaunan yang dapat dikomposkan.'
  }
]

export const items = [
  {
    id: 'item-001',
    slug: 'botol-plastik',
    title: 'Botol Plastik',
    category: 'plastik',
    summary: 'Botol minuman plastik bekas.',
    description: 'Botol plastik bekas minuman yang dapat didaur ulang.',
    imageUrl: 'https://images.pexels.com/photos/3735205/pexels-photo-3735205.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    points: 100,
    unit: 'kg',
    highlights: [
      'Kosongkan botol sebelum disetorkan.',
      'Pisahkan tutup botol jika diperlukan.',
      'Pastikan botol tidak berisi cairan.'
    ]
  },
  {
    id: 'item-002',
    slug: 'kertas-bekas',
    title: 'Kertas Bekas',
    category: 'kertas',
    summary: 'Koran, majalah, dan kertas HVS bekas.',
    description: 'Kertas bekas yang masih kering dan tidak terkontaminasi.',
    imageUrl: 'https://images.pexels.com/photos/2058495/pexels-photo-2058495.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    points: 80,
    unit: 'kg',
    highlights: [
      'Pastikan kertas dalam keadaan kering.',
      'Lepaskan staples dan klip plastik.',
      'Ikat kertas agar mudah dihitung.'
    ]
  },
  {
    id: 'item-003',
    slug: 'kardus-bekas',
    title: 'Kardus Bekas',
    category: 'kardus',
    summary: 'Kardus kemasan yang sudah dilipat.',
    description: 'Kardus bekas kemasan yang bersih dan tidak berminyak.',
    imageUrl: 'https://images.pexels.com/photos/12354555/pexels-photo-12354555.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    points: 70,
    unit: 'kg',
    highlights: [
      'Lipat kardus hingga rata.',
      'Lepaskan selotip yang berlebihan.',
      'Pastikan kardus tidak basah atau berjamur.'
    ]
  },
  {
    id: 'item-004',
    slug: 'kaleng-aluminium',
    title: 'Kaleng Aluminium',
    category: 'logam',
    summary: 'Kaleng minuman aluminium bekas.',
    description: 'Kaleng minuman dari aluminium yang sudah kosong.',
    imageUrl: 'https://images.pexels.com/photos/6591436/pexels-photo-6591436.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    points: 150,
    unit: 'kg',
    highlights: [
      'Kosongkan isi kaleng hingga tidak bersisa.',
      'Bilas kaleng agar tidak lengket.',
      'Remukkan kaleng agar lebih hemat tempat.'
    ]
  },
  {
    id: 'item-005',
    slug: 'botol-kaca',
    title: 'Botol Kaca',
    category: 'kaca',
    summary: 'Botol kaca bekas minuman atau saus.',
    description: 'Botol kaca bekas yang utuh dan tidak pecah.',
    imageUrl: 'https://images.pexels.com/photos/8286621/pexels-photo-8286621.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    points: null,
    unit: 'kg',
    highlights: [
      'Pastikan botol tidak pecah.',
      'Lepaskan label dan tutup logam.',
      'Nilai poin menunggu ketentuan sekolah.'
    ]
  },
  {
    id: 'item-006',
    slug: 'sampah-organik',
    title: 'Sampah Organik',
    category: 'organik',
    summary: 'Sisa sayur, buah, dan dedaunan kering.',
    description: 'Sampah organik yang dapat diolah menjadi kompos.',
    imageUrl: 'https://images.pexels.com/photos/14824327/pexels-photo-14824327.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    points: null,
    unit: 'kg',
    highlights: [
      'Pisahkan dari plastik dan logam.',
      'Hindari sisa makanan yang berminyak.',
      'Nilai poin menunggu ketentuan sekolah.'
    ]
  }
]
