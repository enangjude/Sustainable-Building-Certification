;; Project Registration Contract
;; Records details of construction projects for sustainable certification

(define-data-var last-project-id uint u0)

;; Project status: 0=Registered, 1=In Progress, 2=Completed, 3=Certified
(define-map projects
  { project-id: uint }
  {
    owner: principal,
    name: (string-utf8 100),
    location: (string-utf8 100),
    description: (string-utf8 500),
    registration-date: uint,
    status: uint,
    square-footage: uint
  }
)

(define-read-only (get-project (project-id uint))
  (map-get? projects { project-id: project-id })
)

(define-read-only (get-last-project-id)
  (var-get last-project-id)
)

(define-public (register-project
    (name (string-utf8 100))
    (location (string-utf8 100))
    (description (string-utf8 500))
    (square-footage uint)
  )
  (let
    (
      (new-id (+ (var-get last-project-id) u1))
    )
    (var-set last-project-id new-id)
    (map-set projects
      { project-id: new-id }
      {
        owner: tx-sender,
        name: name,
        location: location,
        description: description,
        registration-date: block-height,
        status: u0,
        square-footage: square-footage
      }
    )
    (ok new-id)
  )
)

(define-public (update-project-status (project-id uint) (new-status uint))
  (let
    (
      (project (unwrap! (get-project project-id) (err u1)))
    )
    ;; Check if caller is the project owner
    (asserts! (is-eq tx-sender (get owner project)) (err u2))
    ;; Check if status is valid (0-3)
    (asserts! (<= new-status u3) (err u3))

    (map-set projects
      { project-id: project-id }
      (merge project { status: new-status })
    )
    (ok true)
  )
)
