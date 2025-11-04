interface PaginationControlsProps {
  currentPage: number;
  totalPages: number;
  onPrev: () => void;
  onNext: () => void;
  onSelect: (page: number) => void;
}

const PaginationControls = ({
  currentPage,
  totalPages,
  onPrev,
  onNext,
  onSelect,
}: PaginationControlsProps) => {
  if (totalPages <= 1) {
    return null;
  }

  return (
    <div className="mt-4 flex items-center justify-center gap-3">
      <button
        type="button"
        onClick={onPrev}
        disabled={currentPage === 0}
        className="flex h-8 w-8 items-center justify-center rounded-full border border-orange-100 bg-white text-sm text-orange-500 transition disabled:cursor-not-allowed disabled:opacity-40 hover:border-orange-200 hover:text-orange-600"
        aria-label="Página anterior"
      >
        <span className="inline-block h-0 w-0 border-y-4 border-y-transparent border-r-4 border-r-orange-500" />
      </button>
      <div className="flex items-center gap-2">
        {Array.from({ length: totalPages }).map((_, index) => (
          <button
            key={index}
            type="button"
            onClick={() => onSelect(index)}
            className={`h-2.5 w-2.5 rounded-full transition ${
              currentPage === index ? 'bg-orange-500' : 'bg-orange-200 hover:bg-orange-300'
            }`}
            aria-label={`Página ${index + 1}`}
          />
        ))}
      </div>
      <button
        type="button"
        onClick={onNext}
        disabled={currentPage >= totalPages - 1}
        className="flex h-8 w-8 items-center justify-center rounded-full border border-orange-100 bg-white text-sm text-orange-500 transition disabled:cursor-not-allowed disabled:opacity-40 hover:border-orange-200 hover:text-orange-600"
        aria-label="Próxima página"
      >
        <span className="inline-block h-0 w-0 border-y-4 border-y-transparent border-l-4 border-l-orange-500" />
      </button>
    </div>
  );
};

export default PaginationControls;
